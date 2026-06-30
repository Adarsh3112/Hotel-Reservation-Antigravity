codeunit 50130 "BSH Reservation Mgt"
{
    procedure AssignRoom(var Reservation: Record "BSH Reservation"; RoomNo: Code[20])
    var
        Room: Record "BSH Room";
    begin
        EnsureOpenReservation(Reservation);
        Reservation.ValidateDates();
        if not Room.Get(RoomNo) then
            Error('Room %1 does not exist.', RoomNo);
        if Room.Blocked then
            Error('Room %1 is blocked.', RoomNo);
        if HasOverlap(Reservation."Reservation No.", RoomNo, Reservation."Check-in Date", Reservation."Check-out Date") then
            Error('Room %1 is unavailable for the selected dates.', RoomNo);

        Reservation.Validate("Room No.", RoomNo);
        Reservation.Modify(true);
    end;

    procedure CheckIn(var Reservation: Record "BSH Reservation")
    var
        Room: Record "BSH Room";
    begin
        EnsureOpenReservation(Reservation);
        if Reservation.Status <> Reservation.Status::Confirmed then
            Error('Only confirmed reservations can be checked in.');
        if Reservation."Room No." = '' then
            Error('A room must be assigned before check-in.');
        if not Room.Get(Reservation."Room No.") then
            Error('Room %1 does not exist.', Reservation."Room No.");
        if HasOverlap(Reservation."Reservation No.", Reservation."Room No.", Reservation."Check-in Date", Reservation."Check-out Date") then
            Error('Room %1 is unavailable for the selected dates.', Reservation."Room No.");

        Reservation.Validate(Status, Reservation.Status::Occupied);
        Reservation.Modify(true);
        Room.Validate(Occupied, true);
        Room.Modify(true);
    end;

    procedure AddServiceCharge(ReservationNo: Code[20]; ChargeType: Enum "BSH Service Charge Type"; Description: Text[100]; Amount: Decimal)
    var
        Reservation: Record "BSH Reservation";
        ServiceCharge: Record "BSH Service Charge";
    begin
        if Amount <= 0 then
            Error('Billable service charge amount must be greater than zero.');
        if not Reservation.Get(ReservationNo) then
            Error('Reservation %1 does not exist.', ReservationNo);
        EnsureOpenReservation(Reservation);

        ServiceCharge.Init();
        ServiceCharge.Validate("Reservation No.", ReservationNo);
        ServiceCharge.Validate("Charge Type", ChargeType);
        ServiceCharge.Validate(Description, Description);
        ServiceCharge.Validate(Amount, Amount);
        ServiceCharge.Validate("Posting Date", Today());
        ServiceCharge.Validate(Billable, true);
        ServiceCharge.Insert(true);
    end;

    procedure CloseReservation(var Reservation: Record "BSH Reservation")
    var
        Room: Record "BSH Room";
    begin
        if Reservation.Status <> Reservation.Status::Occupied then
            Error('Only occupied reservations can be checked out.');
        if Reservation."Invoice No." = '' then
            Error('An invoice must be generated before checkout.');
        if not Reservation."Final Paid" then
            Error('Final payment must be settled before checkout.');

        Reservation.Validate(Status, Reservation.Status::Closed);
        Reservation."Closed At" := CurrentDateTime();
        Reservation.Modify(true);

        if Room.Get(Reservation."Room No.") then begin
            Room.Validate(Occupied, false);
            Room.Modify(true);
        end;
    end;

    procedure HasOverlap(CurrentReservationNo: Code[20]; RoomNo: Code[20]; CheckInDate: Date; CheckOutDate: Date): Boolean
    var
        Reservation: Record "BSH Reservation";
    begin
        if (RoomNo = '') or (CheckInDate = 0D) or (CheckOutDate = 0D) then
            exit(false);

        Reservation.SetRange("Room No.", RoomNo);
        if Reservation.FindSet() then
            repeat
                if (Reservation."Reservation No." <> CurrentReservationNo) and (Reservation.Status <> Reservation.Status::Closed) then
                    if (Reservation."Check-in Date" < CheckOutDate) and (Reservation."Check-out Date" > CheckInDate) then
                        exit(true);
            until Reservation.Next() = 0;
        exit(false);
    end;

    procedure EnsureOpenReservation(Reservation: Record "BSH Reservation")
    begin
        if Reservation.Status = Reservation.Status::Closed then
            Error('Closed reservations cannot be changed.');
    end;
}

codeunit 50122 "BSB Hotel Tests"
{
    Subtype = Test;

    [Test]
    procedure EndToEndLifecycle()
    var
        Reservation: Record "BSB Hotel Reservation";
        Room: Record "BSB Hotel Room";
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        InitializeHotelData();

        CreateRoom('101', 100);
        CreateReservation(Reservation, '101', 100);
        HotelMgt.CaptureDeposit(Reservation, true);
        HotelMgt.CheckIn(Reservation);
        Reservation.Get(Reservation."Reservation No.");
        Assert(Reservation.Status = Reservation.Status::Occupied, 'Reservation should be occupied after check-in.');

        HotelMgt.PostServiceCharge(Reservation."Reservation No.", Enum::"BSB Hotel Service Type"::Breakfast, 25);
        HotelMgt.CheckOut(Reservation);
        Reservation.Get(Reservation."Reservation No.");
        Assert(Reservation.Status = Reservation.Status::Closed, 'Reservation should be closed after checkout.');
        Room.Get('101');
        Assert(not Room.Occupied, 'Room should be released after checkout.');

        HotelMgt.GenerateInvoice(Reservation);
        Reservation.Get(Reservation."Reservation No.");
        Assert(Reservation."Invoice No." <> '', 'Invoice number should be recorded.');
        Assert(Reservation."VAT Amount" >= 0, 'VAT amount should be calculated.');
        HotelMgt.PostFinalPayment(Reservation);
        Reservation.Get(Reservation."Reservation No.");
        Assert(Reservation."Final Payment Posted", 'Final payment should be posted.');
        Assert(Reservation."Remaining Amount" = 0, 'Remaining amount should be settled.');
    end;

    [Test]
    procedure OverbookingIsBlocked()
    var
        FirstReservation: Record "BSB Hotel Reservation";
        SecondReservation: Record "BSB Hotel Reservation";
    begin
        InitializeHotelData();
        CreateRoom('102', 100);
        CreateReservation(FirstReservation, '102', 0);

        SecondReservation.Init();
        SecondReservation.Validate("Customer No.", GetAnyCustomerNo());
        SecondReservation.Validate("Room No.", '102');
        SecondReservation.Validate("Check-in Date", WorkDate() + 1);
        SecondReservation.Validate("Check-out Date", WorkDate() + 3);
        asserterror SecondReservation.Insert(true);
    end;

    [Test]
    procedure FailedDepositDoesNotCapture()
    var
        Reservation: Record "BSB Hotel Reservation";
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        InitializeHotelData();
        CreateRoom('103', 100);
        CreateReservation(Reservation, '103', 100);

        asserterror HotelMgt.CaptureDeposit(Reservation, false);
        Reservation.Get(Reservation."Reservation No.");
        Assert(not Reservation."Deposit Captured", 'Failed deposit must not be captured.');
        Assert(Reservation."Captured Deposit Amt." = 0, 'Failed deposit must not set captured amount.');
    end;

    [Test]
    procedure DuplicateInvoiceIsBlocked()
    var
        Reservation: Record "BSB Hotel Reservation";
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        InitializeHotelData();
        CreateClosedReservation(Reservation, '104');
        HotelMgt.GenerateInvoice(Reservation);
        Reservation.Get(Reservation."Reservation No.");
        asserterror HotelMgt.GenerateInvoice(Reservation);
    end;

    [Test]
    procedure UnauthorizedRefundIsBlocked()
    var
        Reservation: Record "BSB Hotel Reservation";
        RefundMgt: Codeunit "BSB Hotel Refund Mgt.";
    begin
        InitializeHotelData();
        SetCurrentUserRole(Enum::"BSB Hotel User Role"::"Front Desk");
        CreatePaidReservation(Reservation, '105');

        asserterror RefundMgt.ProcessRefund(Reservation, 10);
        Reservation.Get(Reservation."Reservation No.");
        Assert(not Reservation."Refund Posted", 'Unauthorized refund must not be posted.');
    end;

    [Test]
    procedure AuthorizedRefundIsPosted()
    var
        Reservation: Record "BSB Hotel Reservation";
        RefundMgt: Codeunit "BSB Hotel Refund Mgt.";
    begin
        InitializeHotelData();
        CreatePaidReservation(Reservation, '106');
        SetCurrentUserRole(Enum::"BSB Hotel User Role"::Finance);

        RefundMgt.ProcessRefund(Reservation, 10);
        Reservation.Get(Reservation."Reservation No.");
        Assert(Reservation."Refund Posted", 'Finance refund should be posted.');
        Assert(Reservation."Refund Amount" = 10, 'Refund amount should be recorded.');
    end;

    local procedure InitializeHotelData()
    var
        HotelSetup: Record "BSB Hotel Setup";
    begin
        EnsureNoSeries();
        EnsureCustomer();
        EnsureGLAccount('8810');
        EnsureGLAccount('8820');
        EnsureGLAccount('8830');

        HotelSetup.GetRecord();
        HotelSetup.Validate("Res. Nos.", 'BSB-RES');
        HotelSetup.Validate("Deposit Required", true);
        HotelSetup.Validate("Default Deposit %", 20);
        HotelSetup.Validate("Room G/L Account", '8810');
        HotelSetup.Validate("Service G/L Account", '8820');
        HotelSetup.Validate("Deposit G/L Account", '8830');
        HotelSetup.Modify(true);
        SetCurrentUserRole(Enum::"BSB Hotel User Role"::Admin);
    end;

    local procedure EnsureNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get('BSB-RES') then begin
            NoSeries.Init();
            NoSeries.Code := 'BSB-RES';
            NoSeries.Description := 'Hotel Reservations';
            NoSeries.Insert(true);
        end;

        NoSeriesLine.SetRange("Series Code", 'BSB-RES');
        if not NoSeriesLine.FindFirst() then begin
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'BSB-RES';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'RES000001';
            NoSeriesLine."Ending No." := 'RES999999';
            NoSeriesLine.Insert(true);
        end;
    end;

    local procedure EnsureCustomer()
    var
        Customer: Record Customer;
    begin
        if Customer.Get('BSB-CUST') then
            exit;
        Customer.Init();
        Customer."No." := 'BSB-CUST';
        Customer.Name := 'Hotel Test Customer';
        Customer.Insert(true);
    end;

    local procedure EnsureGLAccount(AccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.Get(AccountNo) then
            exit;
        GLAccount.Init();
        GLAccount."No." := AccountNo;
        GLAccount.Name := 'Hotel Account ' + AccountNo;
        GLAccount."Account Type" := GLAccount."Account Type"::Posting;
        GLAccount.Insert(true);
    end;

    local procedure CreateRoom(RoomNo: Code[20]; NightlyRate: Decimal)
    var
        Room: Record "BSB Hotel Room";
    begin
        if Room.Get(RoomNo) then
            Room.Delete(true);
        Room.Init();
        Room.Validate("Room No.", RoomNo);
        Room.Validate("Room Type", 'STD');
        Room.Validate("Nightly Rate", NightlyRate);
        Room.Insert(true);
    end;

    local procedure CreateReservation(var Reservation: Record "BSB Hotel Reservation"; RoomNo: Code[20]; DepositAmount: Decimal)
    begin
        Reservation.Init();
        Reservation.Validate("Customer No.", GetAnyCustomerNo());
        Reservation.Validate("Room No.", RoomNo);
        Reservation.Validate("Check-in Date", WorkDate());
        Reservation.Validate("Check-out Date", WorkDate() + 2);
        Reservation.Validate("Deposit Amount", DepositAmount);
        Reservation.Insert(true);
    end;

    local procedure CreateClosedReservation(var Reservation: Record "BSB Hotel Reservation"; RoomNo: Code[20])
    var
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        CreateRoom(RoomNo, 100);
        CreateReservation(Reservation, RoomNo, 100);
        HotelMgt.CaptureDeposit(Reservation, true);
        HotelMgt.CheckIn(Reservation);
        HotelMgt.PostServiceCharge(Reservation."Reservation No.", Enum::"BSB Hotel Service Type"::Laundry, 15);
        HotelMgt.CheckOut(Reservation);
        Reservation.Get(Reservation."Reservation No.");
    end;

    local procedure CreatePaidReservation(var Reservation: Record "BSB Hotel Reservation"; RoomNo: Code[20])
    var
        HotelMgt: Codeunit "BSB Hotel Mgt.";
    begin
        CreateClosedReservation(Reservation, RoomNo);
        HotelMgt.GenerateInvoice(Reservation);
        Reservation.Get(Reservation."Reservation No.");
        HotelMgt.PostFinalPayment(Reservation);
        Reservation.Get(Reservation."Reservation No.");
    end;

    local procedure GetAnyCustomerNo(): Code[20]
    begin
        exit('BSB-CUST');
    end;

    local procedure SetCurrentUserRole(Role: Enum "BSB Hotel User Role")
    var
        UserRole: Record "BSB Hotel User Role";
    begin
        if UserRole.Get(UserId()) then begin
            UserRole.Role := Role;
            UserRole.Modify(true);
        end else begin
            UserRole.Init();
            UserRole."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserRole."User ID"));
            UserRole.Role := Role;
            UserRole.Insert(true);
        end;
    end;

    local procedure Assert(Condition: Boolean; Message: Text)
    begin
        if not Condition then
            Error(Message);
    end;
}

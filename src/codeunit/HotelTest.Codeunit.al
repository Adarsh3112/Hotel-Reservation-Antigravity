codeunit 50105 "Hotel Test"
{
    Subtype = Test;

    [Test]
    procedure TestOverbooking()
    var
        Room: Record "Hotel Room";
        Res1: Record "Hotel Reservation";
        Res2: Record "Hotel Reservation";
        Res3: Record "Hotel Reservation";
        HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
    begin
        ClearDatabase();

        // 1. Setup Room
        Room.Init();
        Room."Room No." := 'RM01';
        Room."Room Type" := Room."Room Type"::Single;
        Room."Nightly Rate" := 100;
        Room.Insert(true);

        // 2. Setup first reservation (June 20 to June 22)
        Res1.Init();
        Res1."Reservation No." := 'RES01';
        Res1."Room No." := 'RM01';
        Res1."Check-in Date" := DMY2Date(20, 6, 2026);
        Res1."Check-out Date" := DMY2Date(22, 6, 2026);
        Res1.Status := Res1.Status::Confirmed;
        Res1.Insert(true);

        // 3. Try to book overlapping reservation (June 21 to June 23) -> Should Fail
        Res2.Init();
        Res2."Reservation No." := 'RES02';
        Res2."Room No." := 'RM01';
        Res2."Check-in Date" := DMY2Date(21, 6, 2026);
        Res2."Check-out Date" := DMY2Date(23, 6, 2026);
        Res2.Status := Res2.Status::Confirmed;
        
        asserterror Res2.Insert(true);

        // 4. Try to book non-overlapping reservation starting exactly at checkout (June 22 to June 24) -> Should Succeed
        Res3.Init();
        Res3."Reservation No." := 'RES03';
        Res3."Room No." := 'RM01';
        Res3."Check-in Date" := DMY2Date(22, 6, 2026);
        Res3."Check-out Date" := DMY2Date(24, 6, 2026);
        Res3.Status := Res3.Status::Confirmed;
        Res3.Insert(true);
    end;

    [Test]
    procedure TestCheckInRequirement()
    var
        Room: Record "Hotel Room";
        Res: Record "Hotel Reservation";
        HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
    begin
        ClearDatabase();

        // Setup Room
        Room.Init();
        Room."Room No." := 'RM02';
        Room."Room Type" := Room."Room Type"::Double;
        Room."Nightly Rate" := 150;
        Room.Insert(true);

        // Setup Reservation with deposit requirement
        Res.Init();
        Res."Reservation No." := 'RES04';
        Res."Room No." := 'RM02';
        Res."Check-in Date" := DMY2Date(20, 6, 2026);
        Res."Check-out Date" := DMY2Date(22, 6, 2026);
        Res."Deposit Amount" := 100;
        Res.Status := Res.Status::Confirmed;
        Res.Insert(true);

        // Try Check-In without deposit payment -> Should Fail
        asserterror HotelLifecycleMgt.CheckIn(Res);

        // Capture deposit failed payment -> Should Fail
        asserterror HotelLifecycleMgt.CaptureDeposit(Res, false);

        // Capture deposit success -> Should Succeed
        HotelLifecycleMgt.CaptureDeposit(Res, true);
        
        Res.Get('RES04');
        if not Res."Deposit Paid" then
            Error('Expected Deposit Paid to be true.');

        // Now Check-In should succeed
        HotelLifecycleMgt.CheckIn(Res);
        
        Res.Get('RES04');
        if Res.Status <> Res.Status::Occupied then
            Error('Expected reservation status to be Occupied.');

        Room.Get('RM02');
        if not Room.Occupied then
            Error('Expected room to be marked as Occupied.');
    end;

    [Test]
    procedure TestLifecycleFlow()
    var
        Room: Record "Hotel Room";
        Res: Record "Hotel Reservation";
        Service1: Record "Hotel Service Charge";
        Service2: Record "Hotel Service Charge";
        Setup: Record "Hotel Setup";
        HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
        NetAmountDue: Decimal;
    begin
        ClearDatabase();

        // 1. Setup VAT Setup to 10%
        if not Setup.Get() then begin
            Setup.Init();
            Setup.Insert();
        end;
        Setup."VAT %" := 10;
        Setup.Modify();

        // 2. Setup Room (Nightly Rate = 150)
        Room.Init();
        Room."Room No." := 'RM03';
        Room."Room Type" := Room."Room Type"::Suite;
        Room."Nightly Rate" := 150;
        Room.Insert(true);

        // 3. Setup Reservation for 3 nights (June 20 to June 23)
        Res.Init();
        Res."Reservation No." := 'RES05';
        Res."Room No." := 'RM03';
        Res."Check-in Date" := DMY2Date(20, 6, 2026);
        Res."Check-out Date" := DMY2Date(23, 6, 2026);
        Res."Deposit Amount" := 50;
        Res.Status := Res.Status::Confirmed;
        Res.Insert(true);

        // 4. Pay Deposit
        HotelLifecycleMgt.CaptureDeposit(Res, true);

        // 5. Check-In
        Res.Get('RES05');
        HotelLifecycleMgt.CheckIn(Res);

        // 6. Add Service Charges
        Service1.Init();
        Service1."Reservation No." := 'RES05';
        Service1."Line No." := 10000;
        Service1."Service Type" := Service1."Service Type"::Breakfast;
        Service1.Amount := 15;
        Service1.Insert(true);

        Service2.Init();
        Service2."Reservation No." := 'RES05';
        Service2."Line No." := 20000;
        Service2."Service Type" := Service2."Service Type"::Laundry;
        Service2.Amount := 25;
        Service2.Insert(true);

        // 7. Generate Invoice
        Res.Get('RES05');
        HotelLifecycleMgt.GenerateInvoice(Res);

        // Calculations:
        // Room Cost: 3 nights * 150 = 450
        // Service Cost: 15 + 25 = 40
        // Total Net: 490
        // VAT: 10% * 490 = 49
        // Gross Total: 539
        // Deposit Paid: -50
        // Net Due: 539 - 50 = 489
        NetAmountDue := HotelLifecycleMgt.GetNetAmountDue('RES05');
        if NetAmountDue <> 489 then
            Error('Expected Net Amount Due to be 489, but got %1.', NetAmountDue);

        // 8. Settle payment failure -> Should Fail
        Res.Get('RES05');
        asserterror HotelLifecycleMgt.PostFinalPayment(Res, false);

        // 9. Settle payment success
        HotelLifecycleMgt.PostFinalPayment(Res, true);

        NetAmountDue := HotelLifecycleMgt.GetNetAmountDue('RES05');
        if NetAmountDue <> 0 then
            Error('Expected Net Amount Due to be 0 after payment, but got %1.', NetAmountDue);

        // 10. Checkout
        Res.Get('RES05');
        HotelLifecycleMgt.CheckOut(Res);

        Res.Get('RES05');
        if Res.Status <> Res.Status::Closed then
            Error('Expected Reservation to be Closed.');

        Room.Get('RM03');
        if Room.Occupied then
            Error('Expected Room to be released (Occupied = false).');
    end;

    [Test]
    procedure TestTaxRecalculation()
    var
        Room: Record "Hotel Room";
        Res: Record "Hotel Reservation";
        Setup: Record "Hotel Setup";
        HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
        NetAmountDue: Decimal;
    begin
        ClearDatabase();

        // 1. Setup VAT Setup to 10%
        if not Setup.Get() then begin
            Setup.Init();
            Setup.Insert();
        end;
        Setup."VAT %" := 10;
        Setup.Modify();

        // 2. Setup Room (Nightly Rate = 100)
        Room.Init();
        Room."Room No." := 'RM04';
        Room."Room Type" := Room."Room Type"::Single;
        Room."Nightly Rate" := 100;
        Room.Insert(true);

        // 3. Setup Reservation (June 20 to June 21 = 1 night)
        Res.Init();
        Res."Reservation No." := 'RES06';
        Res."Room No." := 'RM04';
        Res."Check-in Date" := DMY2Date(20, 6, 2026);
        Res."Check-out Date" := DMY2Date(21, 6, 2026);
        Res.Status := Res.Status::Confirmed;
        Res.Insert(true);

        HotelLifecycleMgt.CheckIn(Res);

        // 4. Change VAT setup to 15% before invoicing
        Setup.Get();
        Setup."VAT %" := 15;
        Setup.Modify();

        // 5. Generate Invoice (should use 15%)
        Res.Get('RES06');
        HotelLifecycleMgt.GenerateInvoice(Res);

        // Calculations:
        // Room Cost: 1 night * 100 = 100
        // VAT: 15% * 100 = 15
        // Net Due: 115
        NetAmountDue := HotelLifecycleMgt.GetNetAmountDue('RES06');
        if NetAmountDue <> 115 then
            Error('Expected Net Amount Due to be 115 with 15% VAT, but got %1.', NetAmountDue);
    end;

    [Test]
    procedure TestUnauthorizedRefund()
    var
        Room: Record "Hotel Room";
        Res: Record "Hotel Reservation";
        SecurityMgt: Codeunit "Hotel Security Mgt.";
        HotelLifecycleMgt: Codeunit "Hotel Lifecycle Mgt.";
    begin
        ClearDatabase();

        // Setup Room & Res
        Room.Init();
        Room."Room No." := 'RM05';
        Room.Insert(true);

        Res.Init();
        Res."Reservation No." := 'RES07';
        Res."Room No." := 'RM05';
        Res."Deposit Amount" := 100;
        Res.Status := Res.Status::Confirmed;
        Res.Insert(true);

        HotelLifecycleMgt.CaptureDeposit(Res, true);

        // Mock Front Desk user
        SecurityMgt.SetMockRole('HOTEL-FRONTDESK');

        // Front desk attempts refund -> Should Fail
        Res.Get('RES07');
        asserterror HotelLifecycleMgt.ProcessRefund(Res, 50, true);

        // Mock Finance user
        SecurityMgt.SetMockRole('HOTEL-FINANCE');

        // Finance attempts refund -> Should Succeed
        Res.Get('RES07');
        HotelLifecycleMgt.ProcessRefund(Res, 50, true);

        // Verify remaining refundable is 50
        if HotelLifecycleMgt.GetTotalRefunded('RES07') <> 50 then
            Error('Expected refunded amount to be 50.');

        // Try to refund 60 more (Paid: 100, Refunded: 50, Max refundable: 50) -> Should Fail
        asserterror HotelLifecycleMgt.ProcessRefund(Res, 60, true);

        SecurityMgt.ClearMockRole();
    end;

    local procedure ClearDatabase()
    var
        Room: Record "Hotel Room";
        Res: Record "Hotel Reservation";
        Service: Record "Hotel Service Charge";
        Ledger: Record "Hotel Ledger Entry";
    begin
        Room.DeleteAll();
        Res.DeleteAll();
        Service.DeleteAll();
        Ledger.DeleteAll();
    end;
}

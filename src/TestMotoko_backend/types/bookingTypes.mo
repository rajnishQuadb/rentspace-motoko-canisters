module{
    public type BookingInfo = {
        userId : Text;
        bookingDate : Text;
        hotelId : Text;
        checkInDate : Text;
        checkOutDate : Text;
        cancelStatus : Bool;
        refundStatus : Bool;
        bookingDuration : Nat;
        paymentStatus : Bool;
        paymentId : Text;
        bookingId : Text;
    };
    public type BookingInput={
        hotelId :Text;
        checkInDate : Text;
        checkOutDate : Text;
        bookingDuration : Nat;
    };
    public type PaymentType={
        #icp:{id:Nat};
        #ckBTC:{id:Nat};
        #ckETH:{id:Nat};
        #sol;
    };
    public type AnnualData = {
        jan : Nat;
        feb : Nat;
        march : Nat;
        april : Nat;
        may : Nat;
        june : Nat;
        july : Nat;
        aug : Nat;
        sep : Nat;
        oct : Nat;
        nov : Nat;
        dec : Nat;
    };
}
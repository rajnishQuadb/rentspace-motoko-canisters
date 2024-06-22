import Text "mo:base/Text";
import Nat "mo:base/Nat";

module {
    public type Year = Text;
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
    public type UserId = Text;
    public type AdminId = Text;
    public type HotelId = Text;
    public type HotelInfo = {
        hotelId : Text;
        hotelTitle : Text;
        hotelDes : Text;
        hotelImage : Text;
        hotelLocation : Text;
        hotelAvailableFrom : Text;
        hotelAvailableTill : Text;
        createdAt : Text;
    };

    public type RoomType = {
        roomType : Text;
        roomPrice : Nat;
    };

};

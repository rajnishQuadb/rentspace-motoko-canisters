import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";

module {

    public type Year = Text;
    public type UserId = Text;
    public type AdminId = Text;

    public type User = {
        firstName : Text;
        lastName : Text;
        dob : Text;
        userEmail : Text;
    };

    public type UserInfo = {
        userID : Principal;
        firstName : Text;
        lastName : Text;
        dob : Text;
        userEmail : Text;
        userRole : Text;
        userImage : Text;
        userGovID : Text;
        govIDLink : Text;
        isHost : Bool;
        isVerified : Bool;
        agreementStatus : Bool;
        createdAt : Text;
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
};

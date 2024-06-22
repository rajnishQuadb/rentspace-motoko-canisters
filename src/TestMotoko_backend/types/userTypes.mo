import Text "mo:base/Text";
import Nat "mo:base/Nat";
module{
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
    public type AdminId = Text;
    public type UserId = Text;
    public type User = {
        firstName : Text;
        lastName : Text;
        dob : Text;
        userEmail : Text;
    };
    public type UserInfo = {
        firstName : Text;
        lastName : Text;
        dob : Text;
        userEmail : Text;
        userType : Text;
        userProfile : Text;
        userGovId : Text;
        userGovIdLink : Text;
        hostStatus : Bool;
        verificationStatus : Bool;
        createdAt : Text;
        agreementStatus : Bool;
    };
}
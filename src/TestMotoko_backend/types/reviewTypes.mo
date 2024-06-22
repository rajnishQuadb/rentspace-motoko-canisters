import Text "mo:base/Text";
import Float "mo:base/Float";
module{
    public type Review = {
        hotelId : Text;
        rating : Float;
        title : Text;
        des : Text;
        createdAt : Text;
        reviewId: Text;
        userId:Text;
    };
    public type ReviewInput={
        hotelId:Text;
        rating : Float;
        title:Text;
        des:Text;
    }
}
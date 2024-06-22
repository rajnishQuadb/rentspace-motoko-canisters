import Text "mo:base/Text";
module{
        public type Comment = {
            commentId:Text;
            comment : Text;
            hotelId : Text;
            userId : Text;
            parentCommentId : Text;
            createdAt : Text;
        };

        public type CommentInput = {
            message:Text;
            parentCommentId:Text;
        }
}
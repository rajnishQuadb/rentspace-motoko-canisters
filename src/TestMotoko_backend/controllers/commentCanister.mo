import Result "mo:base/Result";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Error "mo:base/Error";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import DateTime "mo:datetime/DateTime";
import CommentTypes "../types/commentTypes";
import UtilityFunc "../utils/utilityFunc";


shared ({caller=owner}) actor class Comment(){

    var commentRecord = TrieMap.TrieMap<Text,[CommentTypes.Comment]>(Text.equal, Text.hash);

    //createCiomment
    //getCommentsonHOtel
    
    //creates on comment on a hotel
    public shared({caller}) func createComment(hotelId:Text,comment:CommentTypes.CommentInput):async Result.Result<CommentTypes.Comment,Text>{
        try{
            //check hotel and user exists
            await UtilityFunc.checkAnonymous(caller);
            let uuid = await UtilityFunc.getUuid();
            let time=DateTime.DateTime(Time.now()).toText();
            let newCommentId = hotelId # uuid;
            let newComment:CommentTypes.Comment={
                comment=comment.message;
                hotelId=hotelId;
                userId=Principal.toText(caller);
                parentCommentId=comment.parentCommentId;
                commentId=newCommentId;
                createdAt=time;
            };
            switch(commentRecord.get(hotelId)){
                case(null){
                    var newComments:Buffer.Buffer<CommentTypes.Comment> = Buffer.fromArray([]);
                    newComments.add(newComment);
                    ignore commentRecord.replace(hotelId,Buffer.toArray(newComments));
                    return #ok(newComment);
                };
                case(?comments){
                    var newComments:Buffer.Buffer<CommentTypes.Comment> = Buffer.fromArray(comments);
                    newComments.add(newComment);
                    ignore commentRecord.replace(hotelId,Buffer.toArray(newComments));
                    return #ok(newComment);
                }
            };
            return #err("Not complete");
        }catch e {
            return #err(Error.message(e));
        }
    };

    // returns comments on a hotel
    public query func getComments(hotelId:Text):async Result.Result<[CommentTypes.Comment],Text>{
        try{
            switch(commentRecord.get(hotelId)){
                case(null){
                    #err("No comments for this hotel")
                };
                case(?comments){
                    #ok(comments);
                }
        }
        }catch e {
            return #err(Error.message(e))
        }

    };

    // returns principal of caller
    public shared({caller}) func whoami():async Text{
        return Principal.toText(caller);
    };

}
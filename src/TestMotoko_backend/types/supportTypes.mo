import Principal "mo:base/Principal";
module{
    public type Address = {
        region : Text;
        streetAddress : Text;
        building : Text;
        city : Text;
        country : Text;
        postalCode : Text;
    };

    public type Ticket = {
        ticketId:Text;
        messageToHost : Text;
        messageToAdmin : Text;
        reason : Text;
        customerId : Text;
        resolved : Bool;
        address : Address;
        createdAt : Text;
    };
    public type TicketInput={
        messageToHost : Text;
        messageToAdmin : Text;
        reason : Text;
        address : Address;
    };
    public type SupportMessage={
        byAdmin:Bool;
        createdAt:Text;
        message:Text;
        from:Principal;
        to:Principal;
    }
}
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

// principal = bn3g7-jel5y-75kmj-enoed-p4dlx-3htlv-yeqhn-crjdv-4ffgc-7cvgm-uqe

//user =  2vxsx-fae

actor Token {
    var owner : Principal = Principal.fromText("bn3g7-jel5y-75kmj-enoed-p4dlx-3htlv-yeqhn-crjdv-4ffgc-7cvgm-uqe");
    let totalSupply : Nat = 1000000000000000;
    let symbol : Text = "DANG";

    private stable var balanceEntries : [(Principal, Nat)] = [];
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
    if (balances.size() < 1) {
        balances.put(owner, totalSupply);
    };

    public query func balanceOf(who : Principal) : async Nat {

        let balance : Nat = switch (balances.get(who)) {
            case null 0;
            case (?result) result;
        };

        return balance;
    };

    public query func getSymbol() : async Text {
        return symbol;
    };

    public shared (msg) func payOut() : async Text {
        Debug.print(debug_show (msg.caller));
        if (balances.get(msg.caller) == null) {
            let amount = 100;
            let result = await transfer(msg.caller, amount);
            return result;
        } else {
            return "Already Claimed";
        };
    };

    public shared (msg) func transfer(to : Principal, amount : Nat) : async Text {
        let fromBalance = await balanceOf(msg.caller);
        if (fromBalance > amount) {
            let newFromBalance : Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance = toBalance + amount;
            balances.put(to, newToBalance);

            return "Success";
        } else {
            return "Insufficient Funds";
        }

    };

    system func preupgrade() {
        balanceEntries := Iter.toArray(balances.entries());
    };

    system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        if (balances.size() < 1) {
            balances.put(owner, totalSupply);
        };
    };

};

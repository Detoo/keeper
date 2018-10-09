pragma solidity ^0.4.24;

// Fusion between a GemJoin and a GemMove

contract GemLike {
    function transferFrom(address,address,uint) public returns (bool);
    function mint(address,uint) public;
    function burn(address,uint) public;
}

contract VatLike {
    function slip(bytes32,bytes32,int) public;
    function move(bytes32,bytes32,int) public;
    function flux(bytes32,bytes32,bytes32,int) public;
}

contract GemMock {
    VatLike public vat;
    bytes32 public ilk;
    GemLike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike(gem_);
    }
    uint constant ONE = 10 ** 27;
    mapping(address => mapping (address => bool)) public can;
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }
    function join(bytes32 urn, uint wad) public {
        require(gem.transferFrom(msg.sender, this, wad));
        vat.slip(ilk, urn, mul(ONE, wad));
    }
    function exit(address guy, uint wad) public {
        require(gem.transferFrom(this, guy, wad));
        vat.slip(ilk, bytes32(msg.sender), -mul(ONE, wad));
    }
    function hope(address guy) public { can[msg.sender][guy] = true; }
    function nope(address guy) public { can[msg.sender][guy] = false; }
    function move(address src, address dst, uint wad) public {
        require(src == msg.sender || can[src][msg.sender]);
        vat.flux(ilk, bytes32(src), bytes32(dst), mul(ONE, wad));
    }
    function push(bytes32 urn, uint wad) public {
        vat.flux(ilk, bytes32(msg.sender), urn, mul(ONE,wad));
    }
}

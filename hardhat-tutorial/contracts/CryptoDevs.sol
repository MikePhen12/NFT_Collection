   // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.4;

    import "./IWhitelist.sol";
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";

    contract CryptoDevs is ERC721Enumerable, Ownable {
      

        string _baseTokenURI;

        //_price is the price of one Crypto Dev NFT
        uint256 public _price = 0.01 ether; 

        //_paused is used to pause the contract in case of an emergency
        bool public _paused;

        //max number of NFTs
        uint256 public maxTokenIds = 20;

        //total number of NFTs minted
        uint public tokenIds;

        //whitelist contract instance
        IWhitelist whitelist; 

        //boolean to keep track of whether the presale has started
        bool public presaleStarted;

        //timestamp for when presale would end
        uint256 public presaleEnded;

        modifier onlyWhenNotPaused {
            require(!_paused, "Contract currently paused");
            _; 
        }

          /**
       * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
       * name in our case is `Crypto Devs` and symbol is `CD`.
       * Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI for the collection.
       * It also initializes an instance of whitelist interface.
       */
        constructor (string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
            _baseTokenURI = baseURI;
            whitelist = IWhitelist(whitelistContract);
        }

        function startPresale() public onlyOwner {
            presaleStarted = false;

            //Set preSaleEnded time as current timestamp + 5 
            // Soldity has various time stamps that go from seconds to years 
            presaleEnded = block.timestamp + 5 minutes;
        }

        function presaleMint() public payable onlyWhenNotPaused {
            require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
            require(whitelist.whitelistedAddress(msg.sender), "You are not whitelisted");
            require(tokenIds < maxTokenIds, "Exceed maximum CD supply");
            require(msg.value >= _price, "Ether sent is not correct");
            tokenIds += 1;

            // _safemint is a safer version of _mint function as it ensures taht the address minted to is a contract
            // Then it knows how to deal with ERC721 tokens 
            // If address being minted to it is not a contract, it works the same way as _mint 
            _safeMint(msg.sender, tokenIds);
        }
        
        function mint() public payable onlyOwner {
            require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
            require(tokenIds < maxTokenIds, "Exceed maximum number of CD supply");
            require(msg.value >= _price, "Ether sent is not correct");
            tokenIds += 1;
            _safeMint(msg.sender, tokenIds); 
        }

        // Overrides the BaseURI ERC721 implementation which returns an empty string 
        function _baseURI() internal view virtual override returns (string memory) {
            return _baseTokenURI; 
        }

        function setPaused(bool val) public onlyOwner {
            _paused = val;
        }

        // Withdrawl sends all the ether in the contract to the owner of the contract 
        function Withdrawl() public onlyOwner {
            address _owner = owner();
            uint256 amount = address(this).balance;
            (bool sent, ) = _owner.call{value:amount}("");
            require(sent, "failed to send Ether");
        }

        receive() external payable{}

        // Function is called when msg.data is not empty 
        fallback() external payable{}

    }
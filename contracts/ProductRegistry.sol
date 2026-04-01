// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProductRegistry {

    // ─── Structs ───────────────────────────────────────────────
    struct Product {
        string  productId;
        string  name;
        string  category;
        string  manufacturerName;
        address manufacturerAddress;
        uint256 registeredAt;
        bool    isRegistered;
    }

    // ─── State Variables ───────────────────────────────────────
    address public owner;

    mapping(string => Product)  private products;        // productId => Product
    mapping(address => bool)    public  manufacturers;   // approved manufacturers
    mapping(address => string[]) private manufacturerProducts; // manufacturer => list of product IDs

    // ─── Events ────────────────────────────────────────────────
    event ProductRegistered(
        string  indexed productId,
        string  name,
        string  manufacturerName,
        address indexed manufacturerAddress,
        uint256 timestamp
    );

    event ManufacturerAdded(address indexed manufacturer);
    event ManufacturerRemoved(address indexed manufacturer);

    // ─── Modifiers ─────────────────────────────────────────────
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyManufacturer() {
        require(manufacturers[msg.sender], "Not an approved manufacturer");
        _;
    }

    modifier productNotExists(string memory productId) {
        require(!products[productId].isRegistered, "Product ID already registered");
        _;
    }

    modifier validString(string memory str) {
        require(bytes(str).length > 0, "Field cannot be empty");
        _;
    }

    // ─── Constructor ───────────────────────────────────────────
    constructor() {
        owner = msg.sender;
        manufacturers[msg.sender] = true; // owner is also a manufacturer
    }

    // ─── Owner Functions ───────────────────────────────────────

    // Add a new approved manufacturer wallet
    function addManufacturer(address _manufacturer) external onlyOwner {
        require(_manufacturer != address(0), "Invalid address");
        require(!manufacturers[_manufacturer], "Already a manufacturer");
        manufacturers[_manufacturer] = true;
        emit ManufacturerAdded(_manufacturer);
    }

    // Remove a manufacturer
    function removeManufacturer(address _manufacturer) external onlyOwner {
        require(manufacturers[_manufacturer], "Not a manufacturer");
        manufacturers[_manufacturer] = false;
        emit ManufacturerRemoved(_manufacturer);
    }

    // ─── Manufacturer Functions ────────────────────────────────

    // Register a new product on the blockchain
    function registerProduct(
        string memory _productId,
        string memory _name,
        string memory _category,
        string memory _manufacturerName
    )
        external
        onlyManufacturer
        productNotExists(_productId)
        validString(_productId)
        validString(_name)
        validString(_manufacturerName)
    {
        products[_productId] = Product({
            productId:           _productId,
            name:                _name,
            category:            _category,
            manufacturerName:    _manufacturerName,
            manufacturerAddress: msg.sender,
            registeredAt:        block.timestamp,
            isRegistered:        true
        });

        manufacturerProducts[msg.sender].push(_productId);

        emit ProductRegistered(
            _productId,
            _name,
            _manufacturerName,
            msg.sender,
            block.timestamp
        );
    }

    // ─── Public Verify Function (free, no gas) ─────────────────

    // Anyone can call this to verify a product
    function verifyProduct(string memory _productId)
        external
        view
        returns (
            bool    isGenuine,
            string  memory name,
            string  memory category,
            string  memory manufacturerName,
            address manufacturerAddress,
            uint256 registeredAt
        )
    {
        Product memory p = products[_productId];

        if (!p.isRegistered) {
            return (false, "", "", "", address(0), 0);
        }

        return (
            true,
            p.name,
            p.category,
            p.manufacturerName,
            p.manufacturerAddress,
            p.registeredAt
        );
    }

    // ─── Getter Functions ──────────────────────────────────────

    // Get all product IDs registered by a manufacturer
    function getManufacturerProducts(address _manufacturer)
        external
        view
        returns (string[] memory)
    {
        return manufacturerProducts[_manufacturer];
    }

    // Check if an address is an approved manufacturer
    function isManufacturer(address _address) external view returns (bool) {
        return manufacturers[_address];
    }

    // Get total products registered by a manufacturer
    function getManufacturerProductCount(address _manufacturer)
        external
        view
        returns (uint256)
    {
        return manufacturerProducts[_manufacturer].length;
    }
}

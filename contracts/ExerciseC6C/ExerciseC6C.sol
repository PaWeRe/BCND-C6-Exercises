pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract ExerciseC6C {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    struct Profile {
        string id;
        bool isRegistered;
        bool isAdmin;
        uint256 sales;
        uint256 bonus;
        address wallet;
    }

    mapping(address => uint256) authorizedCallers; // To check that only App contract can call in!

    address private contractOwner;              // Account used to deploy contract
    mapping(string => Profile) employees;      // Mapping for storing employees

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // No events

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
    * @dev Modifier checking that only the App contract can call in! --> On every "external"
    */
    modifier isCallerAuthorized()
    {
        require(authorizedCallers[msg.sender] == 1, "Caller is not authorized!");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

   /**
    * @dev Check if an employee is registered
    *
    * @return A bool that indicates if the employee is registered
    */   
    function isEmployeeRegistered
                            (
                                string id
                            )
                            external
                            view
                            returns(bool)
    {
        return employees[id].isRegistered;
    }

    /**
    * @dev Check if caller is authorized (after update previous authorization should be deleted -> "deauthorizeContract")
    *
    */
    function authorizeContract(address dataContract) external requireContractOwner {
        authorizedCallers[dataContract] = 1;
    }

    function deauthorizeContract(address dataContract) external requireContractOwner {
        delete authorizedCallers[dataContract];
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function registerEmployee
                                (
                                    string id,
                                    bool isAdmin,
                                    address wallet
                                )
                                external
                                isCallerAuthorized
    {
        require(!employees[id].isRegistered, "Employee is already registered.");

        employees[id] = Profile({
                                        id: id,
                                        isRegistered: true,
                                        isAdmin: isAdmin,
                                        sales: 0,
                                        bonus: 0,
                                        wallet: wallet
                                });
    }

    function getEmployeeBonus
                            (
                                string id
                            )
                            external
                            view
                            isCallerAuthorized
                            returns(uint256)
    {
        return employees[id].bonus;
    }

    function updateEmployee
                                (
                                    string id,
                                    uint256 sales,
                                    uint256 bonus

                                )
                                external
    {
        require(employees[id].isRegistered, "Employee is not registered.");

        employees[id].sales = employees[id].sales.add(sales);
        employees[id].bonus = employees[id].bonus.add(bonus);

    }


}
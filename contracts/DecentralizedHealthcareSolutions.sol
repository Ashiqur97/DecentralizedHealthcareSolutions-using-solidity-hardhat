// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedHealthcareSolutions {

    struct Patient {
        address patientAddress;
        string name;
        uint256 age;
        string gender;
        bool isRegistered;
        bool isBanned;
    }

    struct Doctor {
        address doctorAddress;
        string name;
        string specialization;
        bool isRegistered;
        bool isApproved;
        bool isBanned;
    }

    struct MedicalRecord {
        uint256 recordId;
        string diagnosis;
        string treatment;
        uint256 timestamp;
    }

   struct InsurancePolicy {
        uint256 policyId;
        address insurer;
        uint256 coverageAmount;
        uint256 claimableAmount;
        bool isActive;
    }

    struct TelemedicineConsultation {
        uint256 consultatonId;
        address patient;
        address doctor;
        string notes;
        uint256 timestamp;
        uint256 fee;
        bool isPaid;
    }

    struct SupplyChainItem {
        uint256 itemId;
        string itemName;
        address manufacturer;
        address currentOwner;
        bool isDelivered;
    }

    struct Proposal {
        uint256 proposalId;
        address proposer;
        string description;
        uint256 requestFunding;
        uint256 fundsReceived;
        bool isApproved;
    }

     struct Dispute {
        uint256 disputeId;
        address complainant;
        address respondent;
        string description;
        bool isResolved;
    }


    mapping(address => Patient) public patients;
    mapping (address => Doctor) public doctors;
    mapping (address => MedicalRecord[]) public medicalRecords;
    mapping (address => mapping (address => bool)) public accessGranted;

    mapping (address => InsurancePolicy) public insurancePolicies;
    mapping (address => TelemedicineConsultation) public consultations;
    mapping (uint256 => SupplyChainItem) public supplyChainItems;

    mapping (uint256 => Proposal) public proposals;
    mapping (uint256 => Dispute) public disputes;

    uint256 public proposalCount;
    uint256 public consultationCount;
    uint256 public supplyChainItemCount;
    uint256 public disputeCount;

    address public admin;


    event AdminSet(address indexed admin);
    event PatientRegistered(address indexed patientAddress,string name);
    event DoctorRegistered(address indexed doctorAddress,string name,string specialization);
    event DoctorApproved(address indexed doctorAddress);
    event DoctorBanned(address indexed doctorAddress);

    event RecordAdded(address indexed patientAddress, uint256 recordId, string diagnosis);

    event EmergencyAccessGranted(address indexed patientAddress,address indexed hospital);

    event InsurancePolicyRegistered(address indexed patientAddress,uint256 policyId,uint256 coverageAmount);

    event ClaimProcessed(address indexed patientAddress,uint256 amountClaimed);

    event ConsultationCreated(uint256 indexed consultationId, address indexed patient, address indexed doctor);

    event ConsultationPaid(uint256 indexed consultationId, uint256 amount);

    event SupplyChainItemCreated(uint256 indexed itemId, string itemName, address manufacturer);

    event SupplyChainItemTransferred(uint256 indexed itemId, address newOwner);

    event DisputeRaised(uint256 indexed disputeId, address indexed complainant, address indexed respondent);

    event DisputeResolved(uint256 indexed disputeId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can perform this action");
        _;
    }

    modifier onlyRegisteredPatients() {
         require(patients[msg.sender].isRegistered && !patients[msg.sender].isBanned, "Only registered patients can perform this action.");
         _;
    }

     modifier onlyRegisteredDoctors() {
        require(doctors[msg.sender].isRegistered && doctors[msg.sender].isApproved && !doctors[msg.sender].isBanned, "Only approved doctors can perform this action.");
        _;
    }

    modifier onlyActiveInsurance(address _patient) {
        require(insurancePolicies[_patient].isActive, "Insurance policy is not active.");
        _;
    }



}
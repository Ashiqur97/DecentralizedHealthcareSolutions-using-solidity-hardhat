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
    

}
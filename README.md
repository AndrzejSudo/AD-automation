# Active Directory automation scripts

PowerShell scripts for automating users, groups creation and basic permissions assignment. In current iteration, randomized datasets are used to prepare domain for compromise attempts.

Aside from scripts I did setup Active Directory environment using VMware ESXi hypervisor on bare metal server, hosting Windows Server 2019, 2x Windows 10 Enterprise and Kali linux for enumeration (I planned to add more, but ran out of RAM).

So far I managed to:

1. **Setup a Homelab:**
   - Create a virtual environment using VMware ESXi.
   - Install Windows Server as a domain controller and configure Active Directory.
   - Add two Windows 10 Enterprise workstations to simulate small office environment.

2. **Configure users and groups:**
   - Create and manage randomized users accounts and groups in AD.
   - Implement role-based access control by assigning different permissions to groups.
   - Explore Group Policy Objects (GPOs) for controlling user settings.

3. **Create Organizational Units (OUs):**
   - Organize AD structure using OUs to reflect a real-world organizational hierarchy.
   - Apply group policies selectively to different OUs.

4. **Configure DNS:**
   - Configure DC as DNS server within Domain
   - Learn about DNS integration with Active Directory.
   - Configure and troubleshoot DNS settings within the AD environment.

5. **Group Policy and Security:**
   - Implement security measures using Group Policies.
   - Configure password policies, account lockout policies and audit policies.

6. **Certificate Services:**
   - Implement a Certificate Authority using Active Directory Certificate Services (AD CS).
   - Issue and manage certificates for secure communications within my network.

7. **Monitoring and Logging:**
   - Set up and configure monitoring tools for Active Directory.
   - Monitor security logs and set up alerts for suspicious activities [pending].

8. **PowerShell Scripting:**
   - Learn PowerShell scripting to automate routine AD tasks.
   - Write scripts for user provisioning, group management and permissions assingment.

#TBD:

A. **Active Directory Federation Services (ADFS):**
   - Set up ADFS for single sign-on (SSO) capabilities.
   - Integrate with cloud services like Azure AD to extend AD to the cloud.

B. **Remote Access and VPN:**
   - Configure Remote Access services like DirectAccess or VPN.
   - Explore different authentication methods for remote users.
 
C. **Backup and Disaster Recovery:**
   - Implement a backup strategy for Active Directory.
   - Test and document the process of restoring AD in case of a disaster.
    
D. **Explore Advanced Features:**
   - Investigate and implement features like Active Directory Lightweight Directory Services (AD LDS) for specific scenarios.
   - Learn about Active Directory Rights Management Services (AD RMS) for data protection.


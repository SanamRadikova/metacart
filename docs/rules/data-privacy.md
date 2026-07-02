# Data Privacy and Compliance

## HIPAA
- Beta is **outside HIPAA** (users upload their own lab results)
- Do NOT connect to EHR in MVP
- If moving to B2B in future — will need BAA with each source

## FTC and State Privacy
- Apply even outside HIPAA
- Mandatory: privacy policy + terms of service
- Encryption at rest and in transit
- Role-based access control (RBAC)
- Audit logging

## Research Consent
- IRB text approved
- User must explicitly agree before use
- consent_text_hash (SHA-256) stored as proof
- User can withdraw consent at any time
- After withdrawal, data anonymized but not deleted (for research)

## Pilot Data
- Belongs to CPHE (nonprofit organization)
- Will be used for research and publication
- Anonymized before publication
- Access to raw data — only research team

## Encryption
- All passwords: bcrypt (cost 12)
- All tokens: JWT with RS256
- All data in DB: encryption at rest (AWS RDS encryption)
- All transit: TLS 1.3

## Access Roles
- `metacart_app` — full CRUD for application
- `metacart_analyst` — SELECT only for analysts
- `metacart_admin` — full access (DBA only)

## Audit Log
- All user actions logged
- All data changes logged (old_values, new_values)
- IP address and user agent stored
- Logs stored for 7 years
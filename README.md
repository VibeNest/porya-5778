# 3X-UI — VibeNest deployment package

This repository is prepared for a Docker-based deployment on VibeNest.

## VibeNest settings

1. Import this GitHub repository into VibeNest.
2. Select **Dockerfile** as the build method.
3. Set the service's web port to **8080** if the platform asks for one.
4. Attach persistent storage at **`/etc/x-ui`** before using the panel.
5. Deploy, then immediately set a strong panel username and password.

## Important networking note

A working HTTPS web panel does not guarantee that proxy inbounds are publicly reachable. 3X-UI needs the required public TCP/UDP ports for the configured inbounds. Confirm that the VibeNest plan supports those ports before relying on proxy traffic.

## Persistence and secrets

The database and panel state are stored under `/etc/x-ui`; keep that path on persistent storage. Never commit `.env` files, credentials, private keys, or an existing database to a public repository.

## Build notes

The Dockerfile builds directly from the repository. The duplicate source archive, documentation, screenshots, and Go test files were removed from this deployment copy to reduce repository size and the number of files VibeNest must inspect. Application source, frontend build inputs, translations, and runtime scripts are retained.

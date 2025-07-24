@echo off
REM This Windows batch script ensures that the source mount points in devcontainer.json exist on the host.

echo Ensuring mount points exist...

REM Create .kube and .minikube directories in user profile
if not exist "%USERPROFILE%\.kube" mkdir "%USERPROFILE%\.kube"
if not exist "%USERPROFILE%\.minikube" mkdir "%USERPROFILE%\.minikube"

echo Mount points ensured successfully

########################################################################################################################################################################################
# Setup Dependencies
########################################################################################################################################################################################

# Base image for this is ubuntu 22.04
FROM ubuntu:22.04

# Enable CICD Features
ENV EnableCICDFeaturesForLabVIEW=TRUE

# Set USER as root
ENV USER=root

# Install absolutely needed dependencies
RUN apt-get update && \
	apt-get install -y \
	ca-certificates \
	desktop-file-utils \
	gtk-update-icon-cache \
	libglu1-mesa \
	libx11-6 \
	libxinerama1 \
	xvfb
	
# Fix permission issues for X11
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Make directory for temporarily storing the LabVIEW installer
RUN mkdir -p /home/execs/

# Copy LabVIEW Installer and CEIP Default settings.json
COPY Installer/* /home/execs/
	
########################################################################################################################################################################################	
# Install and Setup LabVIEW
########################################################################################################################################################################################

# Install LabVIEW Pro, LabVIEWCLI, CEIP and VI Analyzer Toolkit
RUN	apt-get install -y /home/execs/ni-labview-2025.deb && \
	apt-get update && \
	apt-get install -y \
	ni-labview-2025-pro \
	ni-labview-command-line-interface \
	ni-ceip \
	ni-vialinux-labview-support
	
# Set necessary INI Tokens to support LabVIEWCLI
# Enable VI Server
RUN mkdir -p /root/natinst/.config/LabVIEW-2025 && \
	echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-2025/labviewprofull.conf && \
	echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-2025/labview.conf && \
	echo "server.tcp.enabled=True" >> /root/natinst/.config/LabVIEW-2025/labview64.conf

# Set unattended token
RUN echo "unattended=True" >> /root/natinst/.config/LabVIEW-2025/labviewprofull.conf && \
	echo "unattended=True" >> /root/natinst/.config/LabVIEW-2025/labview.conf && \
	echo "unattended=True" >> /root/natinst/.config/LabVIEW-2025/labview64.conf
	
# Enable CEIP Logging and Sending
RUN mv -f /home/execs/settings.json /var/local/natinst/udc && \
	chmod 666 /var/local/natinst/udc/settings.json

########################################################################################################################################################################################
# Cleanup
########################################################################################################################################################################################

# Remove installer and settings.json
RUN rm -rf /home/execs/
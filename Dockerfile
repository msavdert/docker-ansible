FROM centos/systemd

MAINTAINER Melih Savdert <melihsavdert@gmail.com>

# Update the operating system
RUN yum makecache fast \
 && yum -y install epel-release \
 && yum -y update

# Install necessary packages
RUN ["yum", "-y", "install", \
       "vim", \
       "which", \
       "sudo", \
       "openssh", \
       "openssh-server", \
       "openssh-clients", \
       "openssl-libs", \
       "net-tools", \
       "ansible", \
       "python-pip"]

# Clean the yum cache
RUN ["yum", "clean", "all"]

# Enable sshd service
RUN systemctl enable sshd

# Add ansible infrastructure owner
RUN ["groupadd", "--force", "ansible"]
RUN useradd --create-home -g ansible ansible

# Give ansible user passwords
RUN echo "ansible:ansible" | chpasswd

# Create SSH shared key directory for the ansible user
RUN ["mkdir", "-p", "-m", "0700", "/home/ansible/.ssh/"]

# Generate SSH shared keys for the ansible user
RUN ssh-keygen -q -C '' -N '' -f /home/ansible/.ssh/id_rsa

# Create the authorized_keys file for the ansible user
RUN cat /home/ansible/.ssh/id_rsa.pub > /home/ansible/.ssh/authorized_keys

# Change ownership of the SSH shared key files for the ansible user
RUN chown -R ansible:ansible /home/ansible/.ssh

# Change permissions of the authorized_keys file for the ansible user
RUN ["chmod", "0640", "/home/ansible/.ssh/authorized_keys"]

# Generate SSH host ECDSA shared keys
RUN ssh-keygen -q -C '' -N '' -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key

RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

RUN chown -R ansible:ansible /etc/ansible/

# Set the environment variables
ENV HOME /root

# Working directory
WORKDIR /root

CMD ["/usr/sbin/init"]


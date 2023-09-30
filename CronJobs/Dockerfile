# Use the Amazon Linux 2 image as the base image
FROM amazonlinux:2

# Update the package manager and install required dependencies
RUN yum update -y && yum install -y \
    python3 \
    python3-pip \
    && yum clean all

# Create a working directory for your application
WORKDIR /app

# Copy your Python script and any other necessary files to the container
COPY your_script.py /app/
# You can also copy any additional files or dependencies your script needs

# Install Python dependencies
RUN pip3 install boto3  # Install the AWS SDK for Python (Boto3) or other dependencies

# Schedule your script to run daily using a cron job
# For example, to run the script every day at 5 AM:
RUN echo "0 5 * * * python3 /app/your_script.py" > /etc/crontab

# Start the cron service
CMD ["crond", "-f"]

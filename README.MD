# SMTP Lab 👨🏻‍🔬

This lab is part of the course **Networks & Communications 2** of **Universidad San Jorge** of Zaragoza. All contents are original.

## Intro

The objective of this lab is to play at a low level with the SMTP protocol to see and "believe" that the principles covered in the theoretical classes of the course are real and functional. There are certain parts of the lab that may not work depending on the system they are executed on, as the behavior of local networks is highly dependent on the specific system. In this case, the important thing is to understand why what is failing is failing, document it in the deliverable, and if there is no obvious solution, continue working with a peer.

### Delivery

The result of the lab is a PDF file with the stated questions answered briefly and concisely in English, including screenshots if requested. If parts of the lab have been done in a group, it must be indicated. If the entire lab has been done in a group due to technical limitations, a single PDF file must be submitted.

It is allowed to use generative AI tools such as ChatGPT for information seeking and research, but if done, it must be specified. The document will be subjected to a heuristic check to determine if it has been generated with generative AI. If so and not explicitly indicated, it will result in the lab being graded with "0".

### Prerequisites

To complete the lab, it is necessary to:

- Have a functional Docker installation. It is recommended to use the most recent version available.
- Have a functional installation of Wireshark.
- Have access to some type of command line system where the `telnet` package is available.
- Have access to a local area network in which firewalls do not apply nor exist partitions, that is, in which all participants can `ping` each other's machines.

## Preliminary steps

1. Determine which are your loopback and local area network adapters you are connected to, as well as your private IP address. Take note of everything.
   1. On Linux / MacOS, do it through the `ifconfig` command.
   2. On Windows, through the `ipconfig` command.
2. Clone this code repository into your working directory.
3. Navigate with the command line to that directory and execute the command `docker compose up -d --build`. Verify that no errors are logged. Once this is the case, shut down the containers again with `docker compose down`.
4. Open Wireshark. Go to Preferences > Advanced. In the search box, type “SMTP”. Select the row `smtp.tcp.port` and change the value from `25` to `1025`. Exceptionally, we will use port `1025` during this lab to avoid conflicts, but it is not the standard. Remember to change it back at the end.

## SMTP

The previously cloned code repository contains a Docker container that runs a very basic SMTP and POP3 server. All security mechanisms have been disabled for clarity, but the configuration is extremely insecure.

This small SMTP server is capable of sending emails between accounts on the same server, as well as to other colleagues' servers on the local area network. Additionally, the POP3 server can retrieve those emails.

### 1. Server configuration

The entire system configuration is centralized in the `docker-compose.yaml` file. You can ignore the rest of the repository's files. In it, you basically need to make three adjustments:

- `USERS` argument. It is a comma-separated list of `user:password` pairs with which you can specify the users who will have access to the mail server. Establish at least one user with your first name and the password you want. For example: `maria:pass123`
- `MY_HOSTNAME` argument. It is the name of the email server's host. That is, the part behind the @ in the email addresses that the server handles. Set it with your last name and the `.local` termination, for example, `garcia.local`
- `FRIENDS` argument. It is the name resolution for your classmates' mail servers, that is, the relationship between hostnames and IP addresses of their servers. If we want to send emails to the mail server of our (fictitious) classmate Diego López, whose hostname is `lopez.local` and running on a machine with IP `192.168.1.145`, we need to specify `lopez.local smtp:[192.168.1.145]:1025`. Multiple resolutions can be specified by separating them with the `|` character.

### 2. Send an email to yourself

Once the configuration is ready, we will send an email to ourselves to see that everything is working. Instead of using a conventional email client, we will use telnet to simulate the commands that the client would send.

1. Start the container again with `docker compose up -d --build`.
2. Open Wireshark, select packet capture on the network loopback interface, and in the filter box, type `smtp`.
3. Open a telnet session to interact directly with the server by executing the command `telnet localhost 1025` in the command line.
4. Once the connection is accepted, you can start typing SMTP commands directly and see the responses. You will see that each command translates into a frame in Wireshark.
5. Enter the sequence of email sending commands we saw in class: `HELO`, `MAIL FROM`, `RCPT TO`, `DATA`, and `QUIT`.
   1. Your email address is the user you configured in `USERS` @ `MY_HOSTNAME`, i.e., for `USERS="maria:pass123` and `MY_HOSTNAME="garcia.local`, your address will be `maria@garcia.local`.
   2. Keep in mind that you are both the sender and the receiver of the message.
   3. When writing the body of the email, add some of the headers we saw in class, at least `Subject`.
6. If everything is done correctly, you will receive a message from the server saying that the email has been queued.
7. Answer these questions:
   1. As what element of the email system are we acting by entering commands in telnet? And the Docker container?
   2. In this operation, is the MTA acting as a client or as a server?
   3. In what format do you see the SMTP commands are traveling in Wireshark?
   4. Show me with a Wireshark screenshot why it is not secure to use SMTP without more security mechanisms.

### 3. Check the email you just sent

Let's check that we have received the email we just sent to ourselves. To do this, we will use POP3.

1. Open a telnet session by typing `telnet localhost 1110`. Again, you can interact normally.
2. Authenticate with the commands `USER <user>` and `PASS <password>` of the user you created during the configuration.
3. Use the `LIST` command to see your email list.
4. Download the first email with `RETR <id>`.
5. Delete the email with `DELE <id>`.
6. Answer these questions:
   1. Did the email arrive correctly? Take a screenshot.
   2. Are there more or fewer headers than the ones you sent? Who added or removed them? Why?
   3. If we were to connect again to the POP3 server from another device, could we see the email again? What alternative do we have?

### 4. Send an email to a classmate

Let's start doing useful things and exchange some emails with a classmate.

1. Choose a classmate and make sure you are on the same local area network. The best way to check is with a `ping` command to see there is visibility between the machines. In case of problems, it usually works to set up a temporary WiFi network with the phone.
2. Exchange your private IP addresses and configure the `FRIENDS` argument in the `docker-compose.yaml` file appropriately. Reload the configuration with `docker compose up -d --build`.
3. Set Wireshark to listen on the local area network interface you are working on and filter again by `smtp`.
4. Follow the steps in section 2 again, but this time direct the email to your classmate.
5. Retrieve the email with POP3 as we did in the previous section.
6. Answer these questions:
   1. Did the emails arrive correctly? Take a screenshot.
   2. Are the frames you are seeing in Wireshark exactly the same as the ones you sent with telnet? Do they contain exactly the same thing? Who is sending them?
   3. Is the MTA acting as a client or as a server in this sending?
   4. What would have happened if the email you sent was directed to a third classmate, whom you do not have in your `FRIENDS` argument but your original classmate does?

### 5. Send an Email with a Serious MUA

For testing purposes, telnet is very visual and gives it a whole 1971 vintage feel... but no one in their right mind sends emails with telnet. We use email clients. Let's test that our system is compatible.

1. Download and install [Thunderbird](https://www.thunderbird.net/es-ES/). It is one of the most used free email clients.
2. Click on the settings wheel > Account Settings > Account Actions > Add Mail Account.p
3. Try adding your `.local` email account. You will have to select “Manual Configuration”. Keep the following in oustanding:
   1. The SMTP port is 1025 instead of the classic 25, and the POP3 port is 1110 instead of the classic 110.
   2. There is no security in the connection.
   3. Authentication is via a normal password.
4. Exchange an email with your classmate using Thunderbird.
5. If the emails do not appear in the inbox upon refreshing, try to load them with telnet as we have done so far.
6. Answer these questions:
   1. Was it received?
   2. What differences do you see in the email headers?
   3. Why can Thunderbird, a modern and serious client, interoperate without any problems with a basic setup like the one we have running in the Docker container?

#!/bin/bash
DIR=`pwd`
fpbx_pass=`awk -F= '/^.*AMPDBPASS/{gsub(/ /,"",$2);print $2}' /etc/freepbx.conf | sed 's/";//;s/"//'`
/usr/bin/echo -en "
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                             \033[37;1;41m Warning!!! \033[0m                                *
* \033[37;1;41m This script tested and work only Sangoma OS 7.X(CentOS 7.X)  or above \033[0m *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
"
/usr/bin/echo -en "Before yousing script ACTIVATE your system"

yum install -y -q dialog
export NCURSES_NO_UTF8_ACS=1

function_us () {
                  ############################################ System update ################################################################################################
                  /usr/bin/echo -e "Update System"
                  /usr/bin/yum update -y
                }

function_mc () {
                ########################################## Install MC #######################################################################################################
                 /usr/bin/echo -e "Installing Midnight commander"
				 yum install mc -y
                }

function_uam () {
                  ############################################ Update all modules asterisk ##################################################################################
                  /usr/bin/echo -e "Update All modules asterisk"
                  /usr/sbin/fwconsole moduleadmin upgradeall
                  /usr/sbin/fwconsole moduleadmin --repo Extended upgradeall
                  /usr/sbin/fwconsole reload
                  # /usr/sbin/fwconsole r
                 }

function_motd () {
                    ############################################ Message of the day #########################################################################################
                    /usr/bin/echo -e "Changing Message of the day"
					/usr/bin/cp -f $DIR/itpr_intro /usr/bin/itpr_intro
                    chmod +x /usr/bin/itpr_intro
                    sed -i '/if \[ -e "$FWCONSOLE" \] ; then/a /usr/bin/itpr_intro' /etc/profile.d/motd.sh
                  }

function_aliases () {
echo "alias ra='fwconsole restart'
alias sip='nano /etc/asterisk/sip_additional.conf'
alias a='asterisk -rvvvvvvvv'
alias a0='asterisk -r'
alias e='nano /etc/asterisk/extensions_custom.conf'
alias d='asterisk -rx "dialplan reload"'
alias s='NCURSES_NO_UTF8_ACS=1 sngrep port 5060'
alias u='asterisk -rx "core show calls uptime"'
alias takeover='/usr/share/heartbeat/hb_takeover'
alias myip='wget -O - -q icanhazip.com'
alias wt='watch -n 0.3 '\''asterisk -x "core show calls"'\'''
alias sngrep='NCURSES_NO_UTF8_ACS=1 sngrep'
alias ax='asterisk -rx "$1"'
" >> /root/.bashrc
                                                case $sip in
                                                1)
echo "alias pp='asterisk -rx "pjsip show contacts" | grep -i '
alias r='asterisk -rx "pjsip show registrations"'
alias p='asterisk -rx "pjsip show contacts"'
" >> /root/.bashrc
                                                ;;
                                                2)
echo "alias pp='asterisk -rx "sip show peers" | grep -i '
alias r='asterisk -rx "sip show registry"'
alias p='asterisk -rx "sip show peers"'
" >> /root/.bashrc
                                                ;;
                                                esac
                                                . ~/.bashrc
                                                }

function_decm () {
 ########################################### Disable enabled commercial modules ############################################################################

                /usr/bin/echo -e "Disable enabled commercial modules"
                # Disable enabled commercial modules
                # CMC - Commercial module count
                # CDC - Count Depended modules
                # CM - Current module
                # Selected row

                /usr/bin/echo "Disabling Modules"
                /usr/sbin/fwconsole moduleadmin remove iotserver
                /usr/sbin/fwconsole moduleadmin remove vega
                SR=1
                CMC=`/usr/sbin/fwconsole moduleadmin list | /usr/bin/grep "Commercial" | /usr/bin/grep "Enabled\|Включен" | /usr/bin/grep -v "sysadmin" | /usr/bin/wc -l`

                    while [ $CMC -gt 0 ]

                          do

                            CM=`/usr/sbin/fwconsole moduleadmin list | /usr/bin/grep "Commercial" | /usr/bin/grep "Enabled\|Включен" | /usr/bin/grep -v "sysadmin" | /usr/bin/awk '{print $2}' | /usr/bin/head -n $SR | /usr/bin/tail -n 1`

                            /usr/bin/echo "Выбраная строка $SR"
                            /usr/bin/echo "Module Number $CMC"
                            /usr/bin/echo "Disabling $CM module"
                            /usr/sbin/fwconsole moduleadmin disable $CM

                            CMC=$[ $CMC - 1 ]
                            SR=$[ $SR + 1 ]

                            CDC=`/usr/sbin/fwconsole moduleadmin list | /usr/bin/grep "Commercial" | /usr/bin/grep "Enabled\|Включен" | /usr/bin/grep -v "sysadmin" | /usr/bin/wc -l`
                            #/usr/bin/echo "$CDC modules remain"
                            /usr/bin/echo "Остаток модулей $CDC остаток строк $CMC"

                            if [ "$CDC" -ne 0 -a "$CMC" = 0 ]

                                then
                                     /usr/bin/echo "Remained not yet disabled&dependent modules, repeat the operation"
                                     /usr/bin/echo "Остались ещё не отключеные, зависимые модули, повторяем операцию"
                                     CMC=$CDC
                                     SR=1
                            fi

                    done

                  /usr/sbin/fwconsole reload
                  }

function_dncm () {
                  ########################################### Disable non-commercial modules #############################################################################
                  /usr/bin/echo -e "Disable non-commercial modules"
                  /usr/bin/echo -e "Disabling Admin modules"
                  /usr/sbin/fwconsole moduleadmin disable asterisk-cli
                  /usr/sbin/fwconsole moduleadmin disable superfecta
                  /usr/sbin/fwconsole moduleadmin disable cidlookup
                  /usr/sbin/fwconsole moduleadmin disable configedit
                  /usr/sbin/fwconsole moduleadmin disable contactmanager
                  /usr/sbin/fwconsole moduleadmin disable digiumaddoninstaller
                  /usr/sbin/fwconsole moduleadmin disable irc
                  /usr/sbin/fwconsole moduleadmin disable pbdirectory
                  /usr/sbin/fwconsole moduleadmin disable presencestate
                  /usr/sbin/fwconsole moduleadmin disable accountcodepreserve
                  /usr/sbin/fwconsole moduleadmin disable xmpp
                  /usr/sbin/fwconsole moduleadmin disable cxpanel
                  # cxpanel - iSymphony
                  # irc - Online support
                  # certman # The following modules depend on this one: ucp,webrtc
                  # phonebook # The following modules depend on this one: pbdirectory,speeddial
                  # pm2 # The following modules depend on this one: api,ucp,xmpp
                  /usr/bin/echo -e "Disabling Applications modules"
                  /usr/sbin/fwconsole moduleadmin disable callforward
                  /usr/sbin/fwconsole moduleadmin disable disa
                  /usr/sbin/fwconsole moduleadmin disable dictate
                  /usr/sbin/fwconsole moduleadmin disable directory
                  /usr/sbin/fwconsole moduleadmin disable donotdisturb
                  /usr/sbin/fwconsole moduleadmin disable findmefollow
                  /usr/sbin/fwconsole moduleadmin disable infoservices
                  /usr/sbin/fwconsole moduleadmin disable tts
                  /usr/sbin/fwconsole moduleadmin disable vmblast
                  /usr/sbin/fwconsole moduleadmin disable hotelwakeup
                  # daynight - Call Flow Control
                  /usr/bin/echo -e "Disabling Connectivity modules"
                  /usr/sbin/fwconsole moduleadmin disable dahdiconfig
                  /usr/sbin/fwconsole moduleadmin disable digium_phones 
                  /usr/sbin/fwconsole moduleadmin disable api
                  /usr/sbin/fwconsole moduleadmin disable webrtc
                  /usr/sbin/fwconsole moduleadmin remove firewall
                  /usr/bin/echo -e "Disabling Reports modules"
                  /usr/sbin/fwconsole moduleadmin disable phpinfo
                  /usr/sbin/fwconsole moduleadmin disable printextensions
                  /usr/bin/echo -e "Disabling Settings modules"
                  /usr/sbin/fwconsole moduleadmin disable fax
                  /usr/sbin/fwconsole moduleadmin disable speeddial
                  /usr/sbin/fwconsole moduleadmin disable ttsengines
                  /usr/sbin/fwconsole moduleadmin disable voicemail
                  # arimanager - The following modules depend on this one: asteriskinfo
                  /usr/sbin/fwconsole reload
                  }

function_asteriks  () {
########################################### AsteriKS Joke #############################################################################
                       /usr/bin/cp -f $DIR/asteriks /usr/bin/asteriks
                       chmod +x /usr/bin/asteriks
                       }

function_sshc () {
########################################## SSH Configuration ##############################################################################################
                  /usr/bin/echo -e "SSH Configuration"
                  # Addin SSH open KEY
                  /usr/bin/mkdir /root/.ssh
                  /usr/bin/touch /root/.ssh/authorized_keys
                  /usr/bin/echo -n "Input the SSH open key: "
                  read SK
                  /usr/bin/echo $SK >> /root/.ssh/authorized_keys
                  /usr/bin/echo "SSH open key added"
                  /usr/bin/sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config
                  /usr/bin/echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
                  /usr/bin/systemctl restart sshd
                  /usr/bin/echo "Now using key authentication only for SSH"
                  }

function_freepbx_logo () {
########################################## Add FIRM Logo ########################################################################################################
                          /usr/bin/cp -f $DIR/logo_small.png /var/www/html/admin/images/logo_small.png
                          /usr/bin/cp -f $DIR/top_logo.png /var/www/html/admin/images/top_logo.png
                          wget -q http://itpr32.ru/itpr_favicon.ico -O /var/www/html/admin/images/itpr_favicon.ico
                          /usr/bin/cp -f $DIR/itpr_favicon.ico /var/www/html/admin/images/itpr_favicon.ico
                          mysql --user=freepbxuser --password=$fpbx_pass asterisk <<EOF
REPLACE INTO \`freepbx_settings\` (\`keyword\`, \`value\`, \`name\`, \`level\`, \`description\`, \`type\`, \`options\`, \`defaultval\`, \`readonly\`, \`hidden\`, \`category\`, \`module\`, \`emptyok\`, \`sortorder\`) VALUES	
('BRAND_IMAGE_FAVICON', 'images/itpr_favicon.ico', 'Favicon', 1, 'Favicon', 'text', '', 'images/favicon.ico', 1, 1, 'Styling and Logos', '', 0, 40),
('BRAND_IMAGE_FREEPBX_LINK_LEFT', 'http://www.itprofit32.ru', 'Link for Left Logo', 1, 'link to follow when clicking on logo, defaults to http://www.freepbx.org', 'text', '', 'http://www.freepbx.org', 1, 0, 'Styling and Logos', '', 1, 100),
('BRAND_IMAGE_SPONSOR_FOOT', 'images/logo_small.png', 'Image: Footer', 1, 'Logo in footer.Path is relative to admin.', 'text', '', 'images/sangoma-horizontal_thumb.png', 1, 0, 'Styling and Logos', '', 1, 50),
('BRAND_IMAGE_SPONSOR_LINK_FOOT', 'http://www.itprofit32.ru', 'Link for Sponsor Footer Logo', 1, 'link to follow when clicking on sponsor logo', 'text', '', 'http://www.sangoma.com', 1, 0, 'Styling and Logos', '', 1, 120),
('BRAND_IMAGE_TANGO_LEFT', 'images/top_logo.png', 'Image: Left Upper', 1, 'Left upper logo.Path is relative to admin.', 'text', '', 'images/tango.png', 1, 0, 'Styling and Logos', '', 0, 40);
EOF

                         }

function_sngrep () {
########################################## Install SNGrep ###################################################################################################
                    centos=$(cat /etc/centos-release-upstream | grep -Eo '[0-9]' | head -n 1)
                    case $centos in
                         6)
                         yum install -e -y http://packages.irontec.com/centos/6/x86_64/sngrep-1.4.6-0.el6.x86_64.rpm
                         ;;
                         7)
                         yum install -q -y http://packages.irontec.com/centos/7/x86_64/sngrep-1.4.6-0.el7.x86_64.rpm
                         ;;
                         *)
                         echo -e "Can't determine centos version. Is it real CentOS? \nTry to get it here http://packages.irontec.com/centos"
                esac
                    }


function_zic () {
                  ########################################## ZabbiX install and configuration ###############################################################################

                  /usr/bin/echo -e "ZabbiX: install and configuration agent"
                  /usr/bin/echo -n "Input your(Firm) external IP. Format X.X.X.X: "
                  read EXIP
                  /usr/bin/echo -n "Input your(Firm) VPN IP. Format X.X.X.X: "
                  read VPNIP
                   /usr/bin/echo -n "Input ZabbiX LISTEN port: "
                  read ZPORT
                  /usr/bin/rpm -Uvh https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
                  /usr/bin/yum install zabbix-agent -y
                  /usr/bin/echo -n "Input your(Client) ZabbiX Hostname. No Spaces: "
                  read ZHN
                  /usr/bin/sed -i '/Server=/d' /etc/zabbix/zabbix_agentd.conf
                  /usr/bin/sed -i '/ListenPort=/d' /etc/zabbix/zabbix_agentd.conf
                  /usr/bin/sed -i '/Hostname=/d' /etc/zabbix/zabbix_agentd.conf
                  /usr/bin/echo "#Generated IT Profit Initial Script
Server=$EXIP,$VPNIP
ListenPort=$ZPORT
Hostname=$ZHN
" >> /etc/zabbix/zabbix_agentd.conf
                  /usr/bin/systemctl enable zabbix-agent
                  /usr/bin/systemctl start zabbix-agent
                  }

function_fc () {
                  ######################################## Automate process enabling and simple configuration net filter for FreePBX ########################################
                  #Pre-HOOKS
                  /usr/sbin/fwconsole firewall stop
                  /usr/sbin/fwconsole firewall disable
                  #last step
                  /usr/sbin/fwconsole reload
                  /usr/sbin/fwconsole restart
                  #Varibles
                  #STATUS=`/usr/bin/systemctl status iptables | /usr/bin/grep "dead" | /usr/bin/wc -l`
                  /usr/bin/echo -n "Input your(Firm) external IP.Format X.X.X.X: "
                  read EXIP
                  /usr/bin/echo -n "Input your(Firm) VPN IP. Format X.X.X.X: "
                  read VPNIP
                  /usr/bin/echo -n "Input your(Client) LocalNET. Format X.X.X.X/X: "
                  read LOCALIPS
                  /usr/bin/echo "# Generated by IT Profit Initial Script
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [18269028:6327157932]
:ADMIN - [0:0]
:IAX2 - [0:0]
:LOCAL - [0:0]
:SERVER - [0:0]
:SIP - [0:0]
:fail2ban-BadBots - [0:0]
:fail2ban-FTP - [0:0]
:fail2ban-SIP - [0:0]
:fail2ban-SSH - [0:0]
:fail2ban-apache-auth - [0:0]
:fail2ban-recidive - [0:0]
-A INPUT -j fail2ban-recidive
-A INPUT -p tcp -m multiport --dports 80,443 -j fail2ban-BadBots
-A INPUT -p tcp -m multiport --dports 21 -j fail2ban-FTP
-A INPUT -j fail2ban-apache-auth
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-SSH
-A INPUT -j fail2ban-SIP
-A INPUT -j fail2ban-SIP
-A fail2ban-BadBots -j RETURN
-A fail2ban-FTP -j RETURN
-A fail2ban-SIP -j RETURN
-A fail2ban-SIP -j RETURN
-A fail2ban-SSH -j RETURN
-A fail2ban-apache-auth -j RETURN
-A fail2ban-recidive -j RETURN
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ADMIN
-A INPUT -p tcp -m tcp --dport 80 -j LOCAL
-A INPUT -p tcp -m tcp --dport 443 -j LOCAL
-A INPUT -p udp -m udp --dport 5060 -j SIP
-A INPUT -p udp -m udp --dport 10000:20000 -j SIP
-A INPUT -p udp -m udp --dport 4569 -j IAX2
-A INPUT -p tcp -m tcp --dport 10559 -j SERVER
-A INPUT -p tcp -m tcp --dport 3306 -j SERVER
-A INPUT -p tcp -m tcp --dport 5038 -j SERVER
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -j DROP
-A ADMIN -s $EXIP/32 -j ACCEPT
-A ADMIN -s $VPNIP/32 -j ACCEPT
-A ADMIN -s $LOCALIPS -j ACCEPT
-A ADMIN -j RETURN
-A LOCAL -s $EXIP/32 -j ACCEPT
-A LOCAL -s $VPNIP/32 -j ACCEPT
-A LOCAL -s $LOCALIPS -j ACCEPT
-A LOCAL -j RETURN
-A SIP -s $EXIP/32 -j ACCEPT
-A SIP -s $VPNIP/32 -j ACCEPT
-A SIP -s $LOCALIPS -j ACCEPT
-A SIP -j RETURN
-A IAX2 -s $EXIP/32 -j ACCEPT
-A IAX2 -j RETURN
-A SERVER -s $EXIP/32 -j ACCEPT
-A SERVER -s $VPNIP/32 -j ACCEPT
-A SERVER -j RETURN
COMMIT
# Completed
" > $DIR/ipt.rules
                  /usr/bin/systemctl enable iptables
                  /usr/bin/systemctl start iptables
                  /usr/sbin/iptables-restore < $DIR/ipt.rules
                  service iptables save
                  }

function_features () {
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.featurecodes SET enabled="0" WHERE enabled="1";'

/usr/sbin/fwconsole reload
                      }

function_sheduler () {

/usr/bin/echo -n "Input your(Firm) E-MAIL for notification: "
read EMAIL
/usr/bin/echo -n "Input your(Firm) system identity for FreePBX: "
read IDENTITY
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.kvstore_FreePBX SET val="$EMAIL" WHERE `key`="notification_emails";'
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.kvstore_FreePBX SET val="$IDENTITY" WHERE `key`="system_ident";'
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.kvstore_FreePBX SET val="disabled" WHERE `key`="auto_system_updates";'
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.kvstore_FreePBX SET val="disabled" WHERE `key`="auto_module_updates";'
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.kvstore_FreePBX SET val="emailonly" WHERE `key`="auto_module_security_updates";'
mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.kvstore_FreePBX SET val="disabled" WHERE `key`="unsigned_module_emails";'
/usr/sbin/fwconsole reload
                     }

function_serverintitle () {

######################################## Include server name in browser ########################################

mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.freepbx_settings SET value="1" WHERE `keyword`="SERVERINTITLE";'

/usr/sbin/fwconsole restart
                      }

function_sipdriver () {

######################################## Choose SIP DRIVER ########################################

    case $sip in
         1)
         mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.freepbx_settings SET value="chan_pjsip" WHERE `keyword`="ASTSIPDRIVER";'
         ;;
         2)
         mysql --user=freepbxuser --password=$fpbx_pass asterisk -e 'UPDATE asterisk.freepbx_settings SET value="chan_sip" WHERE `keyword`="ASTSIPDRIVER";'
    esac

/usr/sbin/fwconsole restart
                        }

#-------------------------------------------------------------------------
result=$(dialog --clear --backtitle "IT PROFIT" --checklist "What do you want to install?:" 0 0 0 \
1 "Update SYSTEM" off \
2 "Update all asterisk modules" off  \
3 "Change Message of the Day" off \
4 "Aliases" off \
5 "Disable enabled commercial modules" off \
6 "Disable non-commercial modules" off  \
7 "Add AsteriKS Joke" off \
8 "Add SSH Open key and Configuring SSHD" off \
9 "Install MC" off \
10 "Add FIRM Logo" off \
11 "Install SNGrep" off \
12 "ZabbiX install and configuration" off \
13 "Automate process enabling and simple configuration net filter for FreePBX" off \
14 "Disable feature codes" off \
15 "Disable All automatic updates" off \
16 "Include server name in browser" off \
17 "Choose SIP DRIVER" off \
2>&1 >/dev/tty)

sip=$(dialog --backtitle "IT PROFIT" --menu "Which sip-driver do you use?:" 0 0 0 \
1 "PJSIP" \
2 "Chan_sip" \
2>&1 >/dev/tty)

clear

for res in $result
        do
          case $res in
                1)
                echo "Update SYSTEM"
                function_us
                echo "Done!"
                ;;
                2)
                echo "Update all asterisk modules"
                function_uam
                echo "Done!"
                ;;
                3)
                echo "Change Message of the Day"
                function_motd
                echo "Done!"
                ;;
                4)
                echo "Adding Aliases"
                function_aliases
                echo "Done!"
                ;;
                5)
                #echo "Disable enabled commercial modules"
                function_decm
                echo "Done!"
                ;;
                6)
                #echo "Disable non-commercial modules"
                function_dncm
                echo "Done!"
                ;;
                7)
                echo "Adding AsteriKS Joke"
                function_asteriks
                echo "Done!"
                ;;
                8)
                echo "Adding SSH Open key and Configuring SSHD"
                function_sshc
                echo "Done!"
                ;;
                9)
                echo "Install MC"
                function_mc
                echo "Done!"
                ;;
                10)
                echo "Add FIRM Logo"
                function_freepbx_logo
                echo "Done!"
                ;;
                11)
                echo "Install SNGrep"
                function_sngrep
                echo "Done!"
                ;;
                12)
                echo "ZabbiX install and configuration"
                function_zic
                echo "Done!"
                ;;
                13)
                echo "Automate process enabling and simple configuration net filter for FreePBX"
                function_fc
                echo "Done!"
                ;;
                14)
                echo "Disabling feature codes"
                function_features
                echo "Done!"
                ;;
                14)
                echo "Disabling all automatic updates FreePBX"
                function_sheduler
                echo "Done!"
                ;;
                15)
                function_serverintitle
                echo "Done!"
                ;;
                15)
                function_sipdriver
                echo "Done!"
      esac
done

/bin/echo COMPLETE


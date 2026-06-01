# File controlled by Puppet/GIT

# bb-hosts_main.inc
page UNIX Tech_Services_Team

title Tech Services Team

subpage TECH Tech Services

group-compress Tech Services Systems
172.20.5.10	nemo	  # http://nemo.vwa.gov.au/ COMMENT:"Cell Server" DESCR:"HP-UX:This the backup server for 222 Exhibition Street" badhttp:2:2:2
# 172.20.5.230	omen      #COMMENT:"DR-Cell Server" DESCR:HP-UX:"DR Cell Server for nemo"
172.29.2.215	omni      #COMMENT:"Linux VM Cell Server"
#172.20.5.224    max       #COMMENT:"Unix Mgnt Server"  http://max.vwa.gov.au/ DESCR:"Unix Management Server" badhttp:2:2:2
172.29.4.154	spusat0201 #COMMENT:"Redhat Satellite Server"
##172.25.109.56   HW2011041    #COMMENT:"David Honeys pc for testing"
##172.25.109.231	james     #COMMENT:"Hobbit Development" DESCR:"Linux RH-4:The Hobbit development and deployment server"
# 172.25.109.230	nick	  #COMMENT:"Unix Admin test server"
#172.29.2.25	lin0025   #COMMENT:"XEN Server"
172.29.2.108	linvm108  #COMMENT:"xymon dr server"
#172.29.2.78	bsl0078   #COMMENT:"Pending rebuild"
#172.29.2.73	bsl0073   #COMMENT:"Pending rebuild"
172.29.2.42     lin0042   #COMMENT:"SAN Mirror backup server"
#172.29.4.33     wdutst0201 #COMMENT:"RHEL 6 test VM" # WR#S114257
#172.29.3.245    lin3245   #COMMENT:"sandpit server"
#172.20.4.27	linv4027  #COMMENT:"Mirror Backup testing"
#172.20.5.232	linsg232  #COMMENT:"Service Guard Node"
#172.20.5.234	linsg234  #COMMENT:"Service Guard Node"
#172.20.3.23	winvmuxc23 #COMMENT:"UXC Jump Box"
# 172.20.3.29	winvmuxc29 #COMMENT:"UXC Jump Box"

subpage VWA VWA Systems

group-compress VWA Systems
#172.29.2.12	aisold	 # COMMENT:"Legacy Agents Warehouse" DESCR:"HP-UX:The legacy Agents Data Warehouse System" NK com disk
#172.29.3.162    ais01dr  # COMMENT:"HAN" DESCR:"HP-UX: Agents Data Warehouse DR System"  
#172.20.5.30	vwahost3  # COMMENT:"HAN" DESCR:"HP-UX: This is a Test Server"
#172.20.5.50	vwahost5  # COMMENT:"Financials" DESCR:"HP-UX: This is the Financials Server" REPORTTIME=W:0700:1900
172.20.5.80     vwahost8 # REPORTTIME=W:0700:1900
172.20.5.81	vwah9old # COMMENT:"Legacy Data Warehouse" DESCR:"HP-UX: This is the OLD Data WareHouse System" REPORTTIME=W:0700:1900
#172.20.5.81	vwah9old # COMMENT:"Legacy Data Warehouse" DESCR:"HP-UX: This is the OLD Data WareHouse System" http://vwah9old.services.workcover.vic.gov.au/ badhttp:2:2:2 REPORTTIME=W:0700:1900
#172.20.5.90	vwahost9 # COMMENT:"Data Warehouse" DESCR:"HP-UX: This is the Data WareHouse System" http://vwahost9.vwa.gov.au/ badhttp:2:2:2 REPORTTIME=W:0700:1900
172.20.5.92	vwah9dr  # COMMENT:"HAN" DESCR:"HP-UX: This is the Legacy Data WareHouse DR System" 
10.56.138.10	wpwcic0201  # COMMENT:"EXH" DESCR:"This EXH CIC system"
10.56.138.11	wpwcic0202  # COMMENT:"EXH" DESCR:"This EXH CIC system"

subpage DWH DWH Systems
include bb-hosts_dwh.inc

subpage CMIP CMIP Systems

group-compress CMIP Systems
172.29.2.29	apex0001  # COMMENT:"Legacy HP/UX MQ server - EXH" DESCR:"HP/UX:MQ server"
172.29.2.30	apex0002  # COMMENT:"Legacy HP/UX MQ server - EXH" DESCR:"HP/UX:MQ server"
172.29.2.10	apex0007  # COMMENT:"Legacy HP/UX MQ server - EXH" DESCR:"HP/UX:MQ server"
172.29.2.28	dbex0001  # COMMENT:"Legacy HP/UX MQ server - EXH" DESCR:"HP/UX:MQ server"
172.29.2.15     dbex0002  # COMMENT:"Legacy HP/UX MQ server - HAN" DESCR:"HP/UX:MQ server"
#172.29.2.20     riskdb   # COMMENT:"apex007"
#172.29.2.54     portaldb # COMMENT:"apex007"

subpage SAN-Systems SAN Systems

group-compress SAN Systems
172.20.5.203	exfcsw1a  # COMMENT:"EXH Fabric A"
172.20.5.204	exfcsw1b  # COMMENT:"EXH Fabric B" 
172.20.5.221	thfcsw11a # COMMENT:"HAN Fabric A" 
172.20.5.222	thfcsw11b # COMMENT:"HAN Fabric B"
172.20.5.118    exlib1    # badconn:3:3:3
172.20.5.119    exlib1fc1 #
172.20.5.120    exlib1fc2 #
172.20.5.121    exlib1fc3 #
172.20.5.122    exlib1fc4 #
172.20.5.115    bolib1    # COMMENT:"HAN"
172.20.5.116    bolibfc1 # COMMENT:"HAN"
172.20.5.111    drslib1  # COMMENT:"HAN"

subpage Remote-Consoles Remote Consoles

# HP/UX remote consoles
group-compress Remote-Consoles
#172.20.5.218    ais0001lc # COMMENT:"HP/UX console for ais0001"
#172.20.5.94     ais01drlc # COMMENT:"HP/UX console for ais01dr"
#172.20.5.211    apex0001lc # COMMENT:"HP/UX console for apex0001"
#172.20.5.212    apex0002lc # COMMENT:"HP/UX console for apex0002"
#172.20.5.217    apex0007lc # COMMENT:"HP/UX console for apex0007"
#172.20.5.201    dbex0001lc # COMMENT:"HP/UX console for dbex0001"
172.20.5.202    dbex0002lc # COMMENT:"HP/UX console for dbex0002"
172.20.5.219    nemolc     # COMMENT:"HP/UX console for nemo"
#172.20.5.54     vwahost5lc
#172.20.5.84     vwahost8lc # COMMENT:"HP/UX console for vwahost8"

## This group includes only iLOs with fixed IPs
group-compress HP Integrated Lights Out
172.20.5.176   	alc0076-ilo   # COMMENT:"HP iLO for alc0076" DESCR:"ILO:Enclosure hppbc6"
172.20.5.177   	alc0077-ilo   # COMMENT:"HP iLO for alc0077" DESCR:"ILO:Enclosure hppbc6"
172.20.5.179   	alc0079-ilo   # COMMENT:"HP iLO for alc0079" DESCR:"ILO:Enclosure thpbc1"
172.20.6.101   	fin0101-ilo   # COMMENT:"HP iLO for fin0101" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.102   	fin0102-ilo   # COMMENT:"HP iLO for fin0102" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.103   	fin0103-ilo   # COMMENT:"HP iLO for fin0103" DESCR:"ILO:Enclosure thcbc1"
172.20.6.104   	fin0104-ilo   # COMMENT:"HP iLO for fin0104" DESCR:"ILO:Enclosure thcbc2"
# 172.20.5.198   	lin0011-ilo   # COMMENT:"HP iLO for lin0011" DESCR:"ILO:Enclosure hppbc3"
# 172.20.5.114   	lin0014-ilo   # COMMENT:"HP iLO for lin0014" DESCR:"ILO:Enclosure thpbc1"
#172.20.5.123   	lin0023-ilo   # COMMENT:"HP iLO for lin0023" DESCR:"ILO:Enclosure hppbc6"
172.20.5.136   	lin0036-ilo   # COMMENT:"HP iLO for lin0036" DESCR:"ILO:Enclosure hppbc5"
172.20.5.139   	lin0039-ilo   # COMMENT:"HP iLO for lin0039" DESCR:"ILO:Enclosure 07SGH614X28M"
172.20.5.42	lin0042-ilo   # COMMENT:"HP iLO for lin0042" DESCR:"ILO:Enclosure hpcbc1"
#172.20.5.151   	lin0051-ilo   # COMMENT:"HP iLO for lin0051" DESCR:"ILO:Enclosure hppbc5"
#172.20.5.189   	lin0064-ilo   # COMMENT:"HP iLO for lin0064" DESCR:"ILO:Enclosure hppbc5"
172.20.5.174   	lin0065-ilo   # COMMENT:"HP iLO for lin0065" DESCR:"ILO:Enclosure hppbc3"
172.20.5.168   	lin0068-ilo   # COMMENT:"HP iLO for lin0068" DESCR:"ILO:Enclosure hppbc6"
#172.20.5.180   	lin0080-ilo   # COMMENT:"HP iLO for lin0080" DESCR:"ILO:Enclosure hppbc4"
#172.20.5.181   	lin0081-ilo   # COMMENT:"HP iLO for lin0081" DESCR:"ILO:Enclosure 07SGH614X28M"
172.20.6.175   	lin0105-ilo   # COMMENT:"HP iLO for lin0105" DESCR:"ILO:Enclosure thcbc2"
#172.20.5.140   	lin0133-ilo   # COMMENT:"HP iLO for lin0133" DESCR:"ILO:Enclosure hppbc7"
#172.20.5.141   	lin0141-ilo   # COMMENT:"HP iLO for lin0141" DESCR:"ILO:Enclosure hppbc4"
#172.20.5.142   	lin0142-ilo   # COMMENT:"HP iLO for lin0142" DESCR:"ILO:Enclosure 07SGH614X28M"
#172.20.5.138   	lin0159-ilo   # COMMENT:"HP iLO for lin0159" DESCR:"ILO:Enclosure hppbc7"
#172.20.3.235   	lin0161-ilo   # COMMENT:"HP iLO for lin0161" DESCR:"ILO:Stand Alone - Hansen Q26"
###172.20.6.91    	lin0191-ilo   # COMMENT:"HP iLO for lin0191" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.199   	lin0199-ilo   # COMMENT:"HP iLO for lin0199" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.200   	lin0200-ilo   # COMMENT:"HP iLO for lin0200" DESCR:"ILO:Enclosure thcbc1"
#172.20.6.127   	lin0209-ilo   # COMMENT:"HP iLO for lin0209" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.128   	lin0210-ilo   # COMMENT:"HP iLO for lin0210" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.217   	lin0217-ilo   # COMMENT:"HP iLO for lin0217" DESCR:"ILO:Enclosure 07SGH614X28M"
172.20.6.219   	lin0219-ilo   # COMMENT:"HP iLO for lin0219" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.220   	lin0220-ilo   # COMMENT:"HP iLO for lin0220" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.229   	lin0229-ilo   # COMMENT:"HP iLO for lin0229" DESCR:"ILO:Enclosure thcbc1"
172.20.6.203   	lin3125-ilo   # COMMENT:"HP iLO for lin3125" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.204   	lin3126-ilo   # COMMENT:"HP iLO for lin3126" DESCR:"ILO:Enclosure thcbc2"
#172.20.6.125   	lin3128-ilo   # COMMENT:"HP iLO for lin3128" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.126   	lin3129-ilo   # COMMENT:"HP iLO for lin3129" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.142   	lin4042-ilo   # COMMENT:"HP iLO for lin4042" DESCR:"ILO:Enclosure hpcbc4"
#172.20.6.161   	lin4061-ilo   # COMMENT:"HP iLO for lin4061" DESCR:"ILO:Enclosure hpcbc4"
#172.20.6.168   	lin4068-ilo   # COMMENT:"HP iLO for lin4068" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.177   	lin4077-ilo   # COMMENT:"HP iLO for lin4077" DESCR:"ILO:Enclosure hpcbc4"
193.200.201.11 	lonqs01-ilo   # COMMENT:"HP iLO for lonqs01" DESCR:"ILO:Stand Alone - Lonsdale St"
# 172.20.5.137	melvwa01-ilo  # COMMENT:"HP iLO for melvwa01" DESCR:"ILO:Stand Alone - EXH"
172.20.6.147   	orae110-ilo   # COMMENT:"HP iLO for orae110" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.129   	orae111-ilo   # COMMENT:"HP iLO for orae111" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.135   	orae112-ilo   # COMMENT:"HP iLO for orae112" DESCR:"ILO:Enclosure thcbc1"
172.20.6.136   	orae113-ilo   # COMMENT:"HP iLO for orae113" DESCR:"ILO:Enclosure thcbc1"
172.20.6.131   	oras114-ilo   # COMMENT:"HP iLO for oras114" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.132   	oras115-ilo   # COMMENT:"HP iLO for oras115" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.133   	oras116-ilo   # COMMENT:"HP iLO for oras116" DESCR:"ILO:Enclosure thcbc1"
172.20.6.134   	oras117-ilo   # COMMENT:"HP iLO for oras117" DESCR:"ILO:Enclosure thcbc1"
#172.20.6.56	sus0025-ilo   # COMMENT:"HP iLO for sus0025" # Decomm by Sam on 25/08/2015
172.20.6.105   	vmes3103-ilo  # COMMENT:"HP iLO for vmes3103" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.253   	vmes3104-ilo  # COMMENT:"HP iLO for vmes3104" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.106   	vmes3106-ilo  # COMMENT:"HP iLO for vmes3106" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.107   	vmes3107-ilo  # COMMENT:"HP iLO for vmes3107" DESCR:"ILO:Enclosure thcbc2"
172.20.6.108   	vmes3108-ilo  # COMMENT:"HP iLO for vmes3108" DESCR:"ILO:Enclosure thcbc2"
172.20.6.109   	vmes3109-ilo  # COMMENT:"HP iLO for vmes3109" DESCR:"ILO:Enclosure thcbc2"
172.20.7.23    	vmes3220-ilo  # COMMENT:"HP iLO for vmes3220" DESCR:"ILO:Enclosure hpcbc4"
172.20.7.24    	vmes3221-ilo  # COMMENT:"HP iLO for vmes3221" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.205   	vmes3174-ilo  # COMMENT:"HP iLO for vmes3174" DESCR:"ILO:Enclosure hpcbc4"
172.20.3.183   	vmes3245-ilo  # COMMENT:"HP iLO for vmes3245" DESCR:"ILO:Enclosure hpcbc3"
#172.20.5.126   	vmesx026-ilo  # COMMENT:"HP iLO for vmesx026" DESCR:"ILO:Enclosure hpcbc5"
172.20.5.149   	vmesx049-ilo  # COMMENT:"HP iLO for vmesx049" DESCR:"ILO:Enclosure hpcbc1"
172.20.5.150   	vmesx050-ilo  # COMMENT:"HP iLO for vmesx050" DESCR:"ILO:Enclosure hpcbc1"
172.20.5.169   	vmesx069-ilo  # COMMENT:"HP iLO for vmesx069" DESCR:"ILO:Enclosure hpcbc2"
#172.20.5.170   	vmesx070-ilo  # COMMENT:"HP iLO for vmesx070" DESCR:"ILO:Enclosure hppbc5"
#172.20.5.185   	vmesx085-ilo  # COMMENT:"HP iLO for vmesx085" DESCR:"ILO:Enclosure hppbc7"
172.20.6.185   	vmesx185-ilo  # COMMENT:"HP iLO for vmesx185" DESCR:"ILO:Enclosure hpcbc1"
172.20.6.186   	vmesx186-ilo  # COMMENT:"HP iLO for vmesx186" DESCR:"ILO:Enclosure hpcbc1"
172.20.6.187   	vmesx187-ilo  # COMMENT:"HP iLO for vmesx187" DESCR:"ILO:Enclosure hpcbc1"
172.20.6.214   	vmesx214-ilo  # COMMENT:"HP iLO for vmesx214" DESCR:"ILO:Enclosure thcbc1"
172.20.6.216   	vmesx216-ilo  # COMMENT:"HP iLO for vmesx216" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.246   	vmesx246-ilo  # COMMENT:"HP iLO for vmesx246" DESCR:"ILO:Enclosure thcbc1"
172.20.6.247   	vmesx247-ilo  # COMMENT:"HP iLO for vmesx247" DESCR:"ILO:Enclosure thcbc1"
172.20.5.190    vwahost9-ilo  # COMMENT:"HP iLO for vwahost9" DESCR:"ILO:Enclosure hppbc6"
172.20.5.192    vwah9dr-ilo   # COMMENT:"HP iLO for vwah9dr" DESCR:"ILO:Enclosure SGH7143EVP"

group-compress iLOs using DHCP (IP may change)
172.20.6.57     lin0195-ilo   # COMMENT:"HP iLO for lin0195" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.54     lin0225-ilo   # COMMENT:"HP iLO for lin0225" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.55     lin0226-ilo   # COMMENT:"HP iLO for lin0226" DESCR:"ILO:Enclosure hpcbc2"
172.20.6.62     lin0228-ilo   # COMMENT:"HP iLO for lin0228" DESCR:"ILO:Enclosure hpcbc2"
172.20.10.103   lin0100-ilo   # COMMENT:"HP iLO for lin0100" DESCR:"ILO:Enclosure hpcbc3"
172.20.6.208    orae118-ilo   # COMMENT:"HP iLO for oras118" DESCR:"ILO:Enclosure hpcbc3"
172.20.7.12     vmes3003-ilo  # COMMENT:"HP iLO for vmes3003" DESCR:"ILO:Enclosure hpcbc4"
172.20.7.20     vmes3004-ilo  # COMMENT:"HP iLO for vmes3004" DESCR:"ILO:Enclosure hpcbc4"
172.20.6.224    lin0196-ilo   # COMMENT:"HP iLO for lin0196" DESCR:"ILO:Enclosure thcbc2"

group-compress C Class Blade Enclosures
172.20.6.10	wpek100201-aoa.vwa.gov.au        # COMMENT:"HP Blade Enclosure 1 - EXH" DESCR:"C Class Enclosure: C7000--RackEXH1 AOA"
172.20.6.13	hpcbc2-aoa.vwa.gov.au        # COMMENT:"HP Blade Enclosure 2 - EXH Primary" DESCR:"C Class Enclosure: C7000--RackEXH2 AOA"
172.20.6.14	hpcbc2-soa.vwa.gov.au        # COMMENT:"HP Blade Enclosure 2 - EXH Secondary" DESCR:"C Class Enclosure: C7000--RackEXH2 SOA"
172.20.6.15	hpcbc3        # COMMENT:"HP Blade Enclosure 3 - EXH" DESCR:"C Class Enclosure: C7000--RackEXH3"
172.20.6.17	hpcbc4        # COMMENT:"HP Blade Enclosure 4 - EXH" DESCR:"C Class Enclosure: C7000--RackEXH4"
172.20.6.20	thcbc1        # COMMENT:"HP Blade Enclosure 1 - HAN" DESCR:"C Class Enclosure: C7000--T26"
172.20.6.22	thcbc2        # COMMENT:"HP Blade Enclosure 2 - HAN" DESCR:"C Class Enclosure: C7000--T26"

subpage LINUX LINUX Systems

group-compress LINUX Systems
# 192.168.222.108 Website	# COMMENT: "Worksafe Internet Site" http://www.workcover.vic.gov.au 
#172.20.5.11	lin0011	# COMMENT:"Splunk logging"
#172.29.2.13	lin0013	# COMMENT:"WEBCM" http://lin0013.services.workcover.vic.gov.au/monitor.html badhttp:2:2:2
172.29.2.14	lin0014	#COMMENT:"WEBCM-DR"  http://lin0014.services.workcover.vic.gov.au/monitor.html badhttp:2:2:2
#172.20.5.23	lin0023	# COMMENT:"Oracle Test server"
172.29.2.36     lin0036	# COMMENT:"WAS" http://lin0036:80/ badhttp:2:2:2 
172.29.2.39     lin0039 # COMMENT:"WAS-DR" http://lin0039:80/ badhttp:2:2:2 
#172.29.2.51     lin0051 # COMMENT:"PACE" http://lin0051:80/ badhttp:2:2:2
172.29.2.64	lin0064	 # COMMENT:"Prod NFS RHCS Cluster - EXH"
172.29.2.65	lin0065  # COMMENT:"Prod NFS RHCS Cluster - EXH"
172.29.2.68	lin0068 # COMMENT:"WCM/Intranet" http://lin0068:80/ badhttp:2:2:2
#172.29.2.84	lin0084  # http://lin0084:80/ badhttp:2:2:2
#172.29.2.98	lin0098	 # COMMENT:"ORR WAS" http://172.29.2.98:9081/iam/server_status.jsp http://172.29.2.98:9082/orr/server_status.jsp   badhttp:2:2:2
#172.29.2.99	lin0099  # COMMENT:"ORR WAS-DR" http://172.29.2.99:9081/iam/server_status.jsp http://172.29.2.99:9082/orr/server_status.jsp   badhttp:2:2:2
172.29.2.100    lin0100  # COMMENT:"WAS-6-EXH" http://lin0100:80/ badhttp:2:2:2
172.29.2.105    lin0105  # COMMENT:"WAS-6-EXH" http://lin0105:80/ badhttp:2:2:2
#172.29.2.133	lin0133  # COMMENT:"eDir_ENT"
#172.29.2.161    lin0161  # COMMENT:"Software Repo"
#172.20.5.162	lin0162	 # COMMENT:"Argos" http://lin0162:80/ badhttp:2:2:2
#172.29.2.163  	lin0163  # COMMENT:"HAN" 
###172.29.2.191	lin0191  # COMMENT:"WAS-Argos" 
172.29.2.195	lin0195	 # COMMENT:"eDir-EMP"
172.29.2.196	lin0196	 # COMMENT:"eDir-EMP-DR"
172.29.2.199	lin0199	 # COMMENT:"WAS-6-EXH"
172.29.2.200	lin0200	 # COMMENT:"WAS-6-DR"
#172.29.2.208	lin0208	 # COMMENT:"Aurion Sandpit"
#172.29.2.209    lin0209  # COMMENT:"SAS Portal"
172.29.2.210    lin0210  # COMMENT:"SAS Metadata"
172.29.2.217  	lin0217  # COMMENT:"WCM/Intranet HAN" http://lin0217:80/ badhttp:2:2:2
172.29.2.219    lin0219  # COMMENT:"WAS 6.1"
172.29.2.220    lin0220  # COMMENT:"WAS 6.1"
172.29.2.225  	lin0225  # COMMENT:"Portal6 Tst Clust"
172.29.2.226  	lin0226  # COMMENT:"Portal6 Tst2 Clust"
172.29.2.228  	lin0228  # COMMENT:"Portal6 Prd1 Clust" http://lin0228:80/ badhttp:2:2:2
172.29.2.229  	lin0229  # COMMENT:"Portal6 Prd2 Clust" http://lin0229:80/ badhttp:2:2:2
172.29.3.125	lin3125  # COMMENT:"OES WAS 6.1" http://lin3125:80/ badhttp:2:2:2
172.29.3.126	lin3126  # COMMENT:"OES WAS 6.1 (HAN)" http://lin3126:80/ badhttp:2:2:2
172.29.3.127	lin3127  # COMMENT:"Prod Internet" http://lin3127.services.workcover.vic.gov.au/wps/wcm/connect/wsinternet/Monitoring/Home/Monitoring badhttp:2:2:2
#172.29.3.128    lin3128  # COMMENT:"SAS OLAP"
172.29.3.129    lin3129  # COMMENT:"SAS Apps"
172.29.4.42	lin4042  # COMMENT:"SAS Dev Apps"
#172.29.4.61	lin4061  # COMMENT:"SAS Dev OLAP"
#172.29.4.68	lin4068  # COMMENT:"SAS Dev Portal"
172.29.4.77	lin4077  # COMMENT:"SAS Dev Metadata"
193.200.201.9   lonqs01  # COMMENT:"SG Quorum server (LON)"
#203.6.223.37    melvwa01 # http://www1.workcover.vic.gov.au/vwa/serviceproviderdirec.nsf/list?openform  notes-port:1352:s:q badnotes-port:2:2:2 badhttp:2:2:2
#172.29.3.25	sus0025	 # COMMENT:"IDM Audit" ## Decomm by Sujoy on 22/04/2015
#As per request S84275/T496617
#172.20.5.31	wtuspl0201 # COMMENT:"SPLUNK Test Server"

subpage Oracle_Servers Oracle Servers

group_compress Oracle_Servers
172.29.3.110    orae110  # COMMENT:"Oracle DB Server"
172.29.3.111    orae111  # COMMENT:"Oracle DB Server"
172.29.3.112    orae112  # COMMENT:"Oracle DB Server HAN"
172.29.3.113    orae113  # COMMENT:"Oracle DB Server HAN"
172.29.3.114    oras114  # COMMENT:"Oracle DB Server"
172.29.3.115    oras115  # COMMENT:"Oracle DB Server"
172.29.3.116    oras116  # COMMENT:"Oracle DB Server HAN"
172.29.3.117    oras117  # COMMENT:"Oracle DB Server HAN"
172.29.5.118    orae118  # COMMENT:"Oracle DB Server"
172.29.5.119    orae119  # COMMENT:"Oracle DB Server"

subpage VMWare_TEST_EXH_Hosts VMWare TEST EXH Hosts
#group-compress VMWare-TEST-Hosts
172.29.3.103	vmes3103 #COMMENT:"Test ESX 3.5 EXH" https://vmes3103/ badhttp:2:2:2
172.29.3.104	vmes3104 #COMMENT:"Test ESX 3.5 EXH" https://vmes3104/ badhttp:2:2:2
172.29.3.106	vmes3106 #COMMENT:"Test ESX 3.5 EXH" https://vmes3106/ badhttp:2:2:2
172.29.2.49	vmesx049 #COMMENT:"Test ESX 3.5 EXH" https://vmesx049/ badhttp:2:2:2
172.29.2.50	vmesx050 #COMMENT:"Test ESX 3.5 EXH" https://vmesx050/ badhttp:2:2:2
172.29.2.69	vmesx069 #COMMENT:"Test ESX 3.5 EXH" https://vmesx069/ badhttp:2:2:2
172.29.3.185	vmesx185 #COMMENT:"Test ESX 3.5 EXH" https://vmesx185/ badhttp:2:2:2
172.29.2.186	vmesx186 #COMMENT:"Test ESX 3.5 EXH" https://vmesx186/ badhttp:2:2:2
172.29.2.187	vmesx187 #COMMENT:"Test ESX 3.5 EXH" https://vmesx187/ badhttp:2:2:2
172.29.2.216	vmesx216 #COMMENT:"Test ESX 3.5 EXH" https://vmesx216/ badhttp:2:2:2

subpage VMWare_TEST_HS_Hosts VMWare TEST HS Hosts
172.29.2.176	vmesx176 #COMMENT:"Test ESX 3.5 HAN" https://vmesx176/ badhttp:2:2:2
172.29.2.246	vmesx246 #COMMENT:"Test ESX 3.5 HAN"  https://vmesx246/ badhttp:2:2:2
172.29.2.247	vmesx247 #COMMENT:"Test ESX 3.5 HAN"  https://vmesx247/ badhttp:2:2:2

subpage VMWare_PROD_222_Hosts VMWare PROD EXH Hosts
#group Exhibition
172.29.3.3	vmes3003 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3003/ badhttp:2:2:2
172.29.3.4	vmes3004 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3004/ badhttp:2:2:2
172.29.3.174	vmes3174 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3174/ badhttp:2:2:2
172.29.3.221	vmes3221 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3221/ badhttp:2:2:2
172.29.3.222	vmes3222 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3222/ badhttp:2:2:2
172.29.3.223	vmes3223 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3223/ badhttp:2:2:2
172.29.3.245	vmes3245 #COMMENT:"Prod ESX 3.5 EXH" https://vmes3245/ badhttp:2:2:2
172.20.5.20	wpuesx0201 #COMMENT:"Prod ESX 4.1 EXH" badconn:2:2:2 https://wpuesx0201/ badhttp:2:2:2
172.20.5.22 	wpuesx0202 #COMMENT:"Prod ESX 4.1 EXH" badconn:2:2:2 https://wpuesx0202/ badhttp:2:2:2
172.20.5.58 	wpuesx0203 #COMMENT:"Prod ESX 4.1 EXH" badconn:2:2:2 https://wpuesx0203/ badhttp:2:2:2

subpage VMWare_PROD_HS_Hosts VMWare PROD HS Hosts
#group Hansen
172.29.2.214	vmesx214 #COMMENT:"Prod ESX 3.5 HAN" badconn:3:3:3 https://vmesx214/ badhttp:2:2:2
172.29.3.107	vmes3107 #COMMENT:"Prod ESX 3.5 HAN" badconn:3:3:3 https://vmes3107/ badhttp:2:2:2
172.29.3.108	vmes3108 #COMMENT:"Prod ESX 3.5 HAN" badconn:3:3:3 https://vmes3108/ badhttp:2:2:2
172.29.3.109	vmes3109 #COMMENT:"Prod ESX 3.5 HAN" badconn:2:2:2 https://vmes3109/ badhttp:2:2:2
172.29.3.220	vmes3220 #COMMENT:"Prod ESX 3.5 HAN" badconn:2:2:2 https://vmes3220/ badhttp:2:2:2
172.20.5.16 	wpuesx0101 #COMMENT:"Prod ESX 4.1 HAN" badconn:2:2:2 https://wpuesx0101/ badhttp:2:2:2
172.20.5.18 	wpuesx0102 #COMMENT:"Prod ESX 4.1 HAN" badconn:2:2:2 https://wpuesx0102/ badhttp:2:2:2
172.20.5.87 	wpuesx0103 #COMMENT:"Prod ESX 4.1 HAN" badconn:2:2:2 https://wpuesx0103/ badhttp:2:2:2

subpage VMWare_PROD_Remote_Hosts VMWare PROD Remote Hosts
#group RemoteESX
192.168.10.14	WPUESX1001 	#COMMENT:"ESX Mildura"
192.168.13.14	WPUESX1201 	#COMMENT:"ESX Mulgrave"
192.168.14.14	WPUESX1101	#COMMENT:"ESX Dandenong"
192.168.18.14	WPUESX0601	#COMMENT:"ESX Bourke St"
192.168.19.14	WPUESX0901	#COMMENT:"ESX Bendigo"
192.168.20.14	WPUESX0801	#COMMENT:"ESX Ballarat"
192.168.21.14	WPUESX0401	#COMMENT:"ESX Geelong"
192.168.22.14	WPUESX1601	#COMMENT:"ESX Shepparton"
192.168.23.14	WPUESX1301	#COMMENT:"ESX Traralgon"
192.168.24.14	WPUESX1501	#COMMENT:"ESX Wangaratta"
192.168.25.14	WPUESX1401	#COMMENT:"ESX Warrnambool"
172.19.200.14	WTVESX9901	#COMMENT:"ESX host Test branch server"
192.168.26.14	WPUESX0501	#COMMENT:"ESX Lonsdale St"
192.168.17.14	WPUESX0701	#COMMENT:"ESX Essendon"


subpage VMWare_Guests VMWare Guests

group-compress VMWare-Guests
# 172.29.2.75	bsl0075	 #COMMENT:"VM"
#172.20.5.13     linvm013 #COMMENT:"NS-Audit"
172.20.5.18     linvm018 #COMMENT:"WAS 6.1 Training"  http://linvm018:80/ badhttp:2:2:2
172.20.5.19     linvm019 #COMMENT:"WAS 6.1 Training"  http://linvm019:80/ badhttp:2:2:2
#172.29.2.22     linvm022 #COMMENT:"CSW eDir temp"
172.29.2.55     linvm055 #COMMENT:"SDT Test server EXH"
172.29.2.59     linvm059 #COMMENT:"SDT Test server EXH"
#172.29.2.70     linvm070 #COMMENT:"MAX DR server cluster"
172.29.2.73     linvm073 #COMMENT:"WAS 6.1 dev" http://linvm073:80/ badhttp:2:2:2
172.29.2.79     linvm079 #COMMENT:"WAS auto deployment framework"
172.29.2.88	linvm088 # COMMENT:"WAS Depl Mgr 6.1.0.29"
172.29.3.30	wauwas0201 # COMMENT:"PAT MIE/EM Depl Mgr 6.1.0.29"
172.29.2.89     bsl0089  #COMMENT:"Xymon Server"
172.29.2.101    linvm101 #COMMENT:"Trillium Server"
172.29.2.102    linvm102 #COMMENT:"Verastream Dev"
172.29.2.103    linvm103 #COMMENT:"Verastream PRD1 EXH"
172.29.2.104    linvm104 #COMMENT:"Verastream PRD2 HAN" 
172.29.2.110	linvm110 #COMMENT:"iWik1"
#172.29.2.111	linvm111 #COMMENT:"WAS MIG LNR Dangerous Goods"
172.29.2.112    linvm112 # http://linvm112:80/ badhttp:2:2:2
172.29.2.114    linvm114 # http://linvm114:80/ badhttp:2:2:2
172.29.2.115    linvm115 # COMMENT:"Production CVS"
172.29.2.116    linvm116 # http://linvm116:80/ badhttp:2:2:2
172.29.2.117    linvm117 # http://linvm117:80/ badhttp:2:2:2
172.29.2.118    linvm118
#172.29.2.119    linvm119
#172.29.2.120    linvm120
172.29.2.121    linvm121    # COMMENT:"first" http://172.29.2.121:18080/firstopac23/ badhttp:2:2:2 
#172.29.2.122    linvm122  # COMMENT:"Test JIRA/Confluence" decomisioned s105783
172.29.2.123    linvm123  #COMMENT:"WAS 6.1 DEV"
172.29.2.125    searchblox    # http://searchblox.services.workcover.vic.gov.au/ badhttp:2:2:2 
172.29.2.126    linvm126 
#172.29.2.126    reflection # COMMENT:"linvm126" http://reflection.services.workcover.vic.gov.au:80/ http://reflection.services.workcover.vic.gov.au:1080/rweb/ badhttp:2:2:2 
172.29.2.126    reflection # COMMENT:"linvm126"
172.29.2.126    socialclub # COMMENT:"linvm126" http://socialclub.services.workcover.vic.gov.au:80/ badhttp:2:2:2 
172.29.2.128	linvm128 #COMMENT:"Prod NFS Cluster Node" http://linvm128:80/ badhttp:2:2:2
172.29.2.129	linvm129 #COMMENT:"Prod NFS Cluster Node" http://linvm129:80/ badhttp:2:2:2
172.29.2.131	linvm131 #COMMENT:"Prod WAS & Tempus Prod - Exh St" http://linvm131:80/ badhttp:2:2:2
172.29.2.132	linvm132 #COMMENT:"Prod WAS & Tempus Prod - Hansen" http://linvm132:80/ badhttp:2:2:2
172.29.2.135	linvm135 #COMMENT:"ELS Test WAS" http://linvm135:80/ badhttp:2:2:2
172.29.2.136	linvm136 #COMMENT:"ELS Test WAS" http://linvm136:80/ badhttp:2:2:2
#172.29.2.127    linvm127 #COMMENT:"WEBCM-Dev"  http://linvm127:80/ badhttp:2:2:2
# linvm129 decomm'd 06/04/10 ITSS121486
#172.29.2.129    linvm129 #COMMENT:"WEBCM-Authoring" http://linvm129:80/ badhttp:2:2:2
#172.29.2.130    linvm130 #COMMENT:"WEBCM-Staging" http://linvm130:80/ badhttp:2:2:2
#172.29.2.143    linvm143 #COMMENT:"DR-ORR"
#172.29.2.144    linvm144 #COMMENT:"DR-ORR"
#172.29.2.145    linvm145 #COMMENT:"DR-ORR Wiki"
#172.29.2.146    linvm146 #COMMENT:"DR-ORR"
#172.29.2.147    linvm147 #COMMENT:"DR-ORR"
#172.29.2.148    linvm148 #COMMENT:"DR-ORR"
172.29.2.149    linvm149 #COMMENT:"DR-PACE"
172.29.2.154	linvm154 #COMMENT:"Appliance Bckups"
172.29.2.158    linvm158 #COMMENT:"WebSphere Training"
172.29.2.160	linvm160 #COMMENT:"FunnelBack"
172.29.2.124	linv0124 #COMMENT:"FunnelBack Production" http://linv0124:80" badhttp:2:2:2
172.29.2.156	linv0156 #COMMENT:"FunnelBack Test" http://linv0156:80" badhttp:2:2:2
172.29.2.162	linvm162 #COMMENT:"WAS 6.1 UAT" http://linvm162:80/ badhttp:2:2:2
172.29.2.165	linvm165 #COMMENT:"WAS6 Deploy"
172.29.2.166	linvm166 #COMMENT:"WAS6 Portal"
172.29.2.167	linvm167 #COMMENT:"WAS6 Portal"
172.29.2.188	linvm188 #COMMENT:"WAS6 App"
#172.29.2.189	linvm189 #COMMENT:"WAS6 App" #WAS INT Test server which has been power off in VM
172.29.2.227  	linvm227 #COMMENT:"Portal6 TST D-Mgr"
172.29.2.218  	linvm218 #COMMENT:"WAS 6.1 UAT" http://linvm218:80/ badhttp:2:2:2
172.29.2.232  	linvm232 #COMMENT:"Portal6 PRD D-Mgr"
#172.29.2.251	linvm251 #COMMENT:"Argos D-Mgr TEST" 
172.29.3.33	linv3033 #COMMENT:"Intranet Dep Mgr"
172.29.3.34	linv3034 #COMMENT:"iLog"
172.29.2.127	linvm127 #COMMENT:"iLog TEST"
172.29.3.35	linv3035 #COMMENT:"QAS DEV"
172.29.3.36	linv3036 #COMMENT:"QAS PRD1 EXH"
172.29.3.37	linv3037 #COMMENT:"QAS PRD2 HAN" badconn:2:2:2
10.57.97.60     tpucba0301 #COMMENT:"Tac cba server"
10.57.97.61     tpaaep0301 #COMMENT:"TAC aep server"
172.29.3.38	linv3038 #COMMENT:"Dev Team JIRA/Hudson"
172.29.3.72	linv3072 #COMMENT:"WorkHealth PRD1 EXH"
172.29.3.73	linv3073 #COMMENT:"WorkHealth PRD2 HAN"
#172.29.3.90	linv3090 #COMMENT:"Intranet Redevel" #Request T611069/S108471 on 17/12/2015
#172.29.3.102    linv3102 #
172.29.3.132    linv3132 #COMMENT:"WCM Server"
172.29.3.133    linv3133 #COMMENT:"WCM Server" 
172.29.3.134    linv3134 #COMMENT:"OES DEV HAN"
172.29.3.208    linv3208 #COMMENT:"OES SIT1 HAN"
172.29.3.209    linv3209 #COMMENT:"OES SIT2 HAN"
172.29.3.210    linv3210 #COMMENT:"OES UAT1 HAN"
172.29.3.211    linv3211 #COMMENT:"OES UAT2 HAN"

172.29.2.56     linvm056 #COMMENT:"BRMS-B - Test" http://linvm056:80/ badhttp:2:2:2
172.29.2.57     linvm057 #COMMENT:"BRMS UAT and SIT Depl Mgr"
172.29.2.58     linvm058 #COMMENT:"RTS-QA"
172.29.2.61     linvm061 #COMMENT:"BRMS-C - Test"
172.29.2.77     linvm077 #COMMENT:"BRMS-A - Dev"
172.28.4.84     linvm084 #COMMENT:"BRMS-Prod"
172.28.4.97     linvm097 #COMMENT:"BRMS-Prod"
172.29.2.98	linvm098 #COMMENT:"ELS Prod AV - Exh St"
172.29.2.99	linvm099 #COMMENT:"ELS Prod AV - Hansen"
172.29.2.190    linvm190 #COMMENT:"MIE & EM - SIT  WSV" http://linvm190:80/ badhttp:2:2:2
172.29.2.192    linvm192 #COMMENT:"BRMS-CIB - Dev"
172.28.2.156    linvm156 #COMMENT:"BRMS-PAT" http://linvm156:80/ badhttp:2:2:2
#172.29.2.222    linvm222 #COMMENT:"MIE & EM - PAT  TAC & WSV"
172.29.2.223    linvm223 #COMMENT:"RES-QA" http://linvm223:80/ badhttp:2:2:2
172.28.2.230	linvm230 #COMMENT:"BRMS PAT Depl Mgr"
172.29.2.231	linvm231 #COMMENT:"MIE & EM - Trn"  http://linvm231:80/ badhttp:2:2:2
172.28.2.250    linvm250 #COMMENT:"BRMS-PAT" http://linvm250:80/ badhttp:2:2:2
#172.29.2.252    linvm252 #COMMENT:"MIE & EM - PAT  TAC"
172.29.3.12     linv3012 #COMMENT:"MIE & EM - PAT  WSV/TAC"
# 172.29.3.14     linv3014 #COMMENT:"MIE & EM - PAT  TAC"
172.29.3.22     linv3022 #COMMENT:"BRMS-D, PAT, Prod & RTS-QA"
172.29.3.49     linv3049 #COMMENT:"MIE & EM - PAT  WSV/TAC"
172.29.3.51     linv3051 #COMMENT:"MIE & EM - UAT  TAC & WSV"
172.29.3.69     linv3069 #COMMENT:"MIE & EM - UAT  TAC & WSV"
172.28.4.81	linv3081 #COMMENT:"BRMS Prod Depl Mgr"
172.29.3.150    linv3150 #COMMENT:"BRMS-A & BRMS-CIB"
172.29.3.179    linv3179 #COMMENT:"BRMS-A - Dev" http://linv3179:80/ badhttp:2:2:2
172.29.3.247    linv3247 #COMMENT:"BRMS-D - Trn"
172.29.3.251	linv3251 #COMMENT:"WAS"
# 172.29.3.254    linv3254 #COMMENT:"Test for WPS Client" - "Server powered off"
172.29.4.24	linv4024 #COMMENT:"SDT WAS 7 Depl Mgr"
#172.29.4.25	linv4025 #COMMENT:"Jira PROD" http://linv4025:80/ badhttp:2:2:2
#172.29.4.26	linv4026 #COMMENT:"SVN Repository" http://linv4026:80/ badhttp:2:2:2
172.29.4.27	linv4027 #COMMENT:"Snap/mirror backup testing"
172.28.4.19     linv3019 #COMMENT:"EIP PROD MQ Cluster"
172.28.4.99     linv3099 #COMMENT:"EIP PROD MQ Cluster"
#172.29.3.20     linv3020 #COMMENT:"EIP PROD WMB RAD MQ Cluster"
192.168.224.20     linv3020 #COMMENT:"EIP PROD BROKER MQ Cluster -HICAPS"
#172.29.3.80     linv3080 #COMMENT:"EIP PROD BROKER MQ Cluster -HICAPS"
192.168.224.80     linv3080 #COMMENT:"EIP PROD WMB RAD MQ Cluster"
172.28.4.16     linv3016 #COMMENT:"EIP PROD NDM"
172.28.4.17     linv3017 #COMMENT:"EIP PROD WPS1"
172.28.4.18     linv3018 #COMMENT:"EIP PROD WESB1" http://linv3018:80/ badhttp:2:2:2
172.28.4.32     linv3032 #COMMENT:"EIP PROD WESB2" http://linv3032:80/ badhttp:2:2:2
172.28.4.14     linvm4014 #COMMENT:"EIP PROD WESB3" http://linv3018:80/ badhttp:2:2:2
172.28.4.15     linvm4015 #COMMENT:"EIP PROD WESB4" http://linv3018:80/ badhttp:2:2:2
172.28.4.30     linv3030 #COMMENT:"EIP PROD WPS2"
172.29.2.224    linvm224 #COMMENT:"EIP PAT WMB RAD MQ"
172.28.2.243    linvm243 #COMMENT:"EIP PAT MQ"
172.28.2.244    linvm244 #COMMENT:"EIP PAT WESB1" http://linvm244:80/ badhttp:2:2:2
172.28.2.249    linvm249 #COMMENT:"EIP PAT WPS1"
172.28.2.253    linvm253 #COMMENT:"EIP PAT WPS2"
172.28.2.254    linvm254 #COMMENT:"EIP PAT WESB2" http://linvm254:80/ badhttp:2:2:2
172.28.2.12    linvm2012 #COMMENT:"EIP PAT WESB3" http://linvm2012:80/ badhttp:2:2:2
172.28.2.13    linvm2013 #COMMENT:"EIP PAT WESB4" http://linvm2013:80/ badhttp:2:2:2
172.28.2.124    linvm124 #COMMENT:"EIP PAT NDM"
172.29.4.14	linv4014 #COMMENT:"EIP/ELS PAT NFS Cluster"
172.29.4.16	linv4016 #COMMENT:"EIP/ELS PAT NFS Cluster"
172.29.3.7      linv3007 #COMMENT:"EIP UAT WPS2"
172.29.3.8	linv3008 #COMMENT:"EIP UAT WESB1" http://linv3008:80/ badhttp:2:2:2
172.29.3.9	linv3009 #COMMENT:"EIP UAT WESB2" http://linv3009:80/ badhttp:2:2:2
172.29.3.97     linv3097 #COMMENT:"EIP UAT WPS1"
172.29.3.100    linv3100 #COMMENT:"EIP UAT NDM"
172.29.3.98     linv3098 #COMMENT:"EIP UAT MQ"
172.29.3.229    linv3229 #COMMENT:"EIP UAT WMB RAD MQ"
172.29.3.91     linv3091 #COMMENT:"EIP SIT WESB1" http://linv3091:80/ badhttp:2:2:2
172.29.3.92     linv3092 #COMMENT:"EIP SIT WESB2" http://linv3092:80/ badhttp:2:2:2
172.29.3.93     linv3093 #COMMENT:"EIP SIT WPS1"
172.29.3.94     linv3094 #COMMENT:"EIP SIT WPS2"
172.29.3.231    linv3231 #COMMENT:"EIP SIT MQ"
# not implemented 172.29.3.232    linv3232 #COMMENT:"EIP SIT MQ2"
#172.29.3.5	linv3005 #COMMENT:"EIP DEV MBRAD"
172.29.3.6      linv3006 #COMMENT:"EIP TRN WMB RAD MQ"
172.29.3.95     linv3095 #COMMENT:"EIP DEV TEAM"
172.29.3.212    linv3212 #COMMENT:"EIP DEV CIB NDM"
172.29.3.228    linv3228 #COMMENT:"EIP DEV TRN MQ"
#172.29.3.83     linv3083 #COMMENT:"EIP EXP WESB1"
#172.29.3.84     linv3084 #COMMENT:"EIP EXP WESB2"
#172.29.3.85     linv3085 #COMMENT:"EIP EXP WPS1"
172.29.3.10     linv3010 #COMMENT:"EIP TRN WPS WESB" http://linv3010:80/ badhttp:2:2:2
172.29.2.143	linvm143 #COMMENT:"Prod NFS MCSG Cluster"
172.29.2.144	linvm144 #COMMENT:"Prod NFS MCSG Cluster"
172.29.3.39	linv3039 #COMMENT:"Non-prod NFS RHCS Cluster & WAS SIT Dmgr"
172.29.3.71	linv3071 #COMMENT:"Non-prod NFS RHCS Cluster & WAS SIT Dmgr"
172.29.2.23	linvm023 #COMMENT:"DR NFS / EIP Backup"
#172.29.3.202    linv3202 #COMMENT:"TAC Aurion PROD - EXH"
#172.29.3.206    linv3206 #COMMENT:"TAC Aurion DEV - HAN"
#172.29.3.207    linv3207 #COMMENT:"TAC Aurion TRN - HAN"
#172.29.3.233    linv3233 #COMMENT:"VWA Aurion Test - EXH"
#172.29.3.239    linv3239 #COMMENT:"VWA Aurion TRAIN - EXH"
#172.29.3.240    linv3240 #COMMENT:"VWA Aurion PROD - EXH"
172.29.3.171    linv3171 #COMMENT:"SDT Prod EXH" http://linv3171:8180/ badhttp:2:2:2
172.29.3.172    linv3172 #COMMENT:"SDT Prod HAN" http://linv3172:8180/ badhttp:2:2:2
172.29.3.173    linv3173 #COMMENT:"SDT Prod EXH" http://linv3173:8180/ badhttp:2:2:2
172.29.3.176    linv3176 #COMMENT:"SDT Prod HAN" http://linv3176:8180/ badhttp:2:2:2
172.29.3.214    linv3214 #COMMENT:"SDT Training server EXH"
172.29.2.76	linvm076 #COMMENT:"SDT Dev HAN"
172.29.2.163	linvm163 #COMMENT:"SDT Dev HAN"
# 203.6.223.47    melvwa02 # http://www2.workcover.vic.gov.au/vwa/serviceproviderdirec.nsf/list?openform	notes-port:1352:s:q badhttp:2:2:2
172.29.4.101	wtuwas0101 #COMMENT:"DM Test NDM EXH"
172.29.4.102    wtuwas0102 #COMMENT:"DM Test SERVICE EXH" http://wtuwas0102:80/ badhttp:2:2:2
172.29.4.103    wtuwas0103 #COMMENT:"DM Test ENGINE EXH"
172.29.4.104    wtuwas0201 #COMMENT:"DM Test SERVICE HS" http://wtuwas0201:80/ badhttp:2:2:2
172.29.4.105    wduwas0101 #COMMENT:"DM Dev SERVICE HS" http://wduwas0101:80/ badhttp:2:2:2
172.29.4.106    wduwas0102 #COMMENT:"DM Dev SERVICE EXH" http://wduwas0102:80/ badhttp:2:2:2
172.29.4.107    wduwas0103 #COMMENT:"DM Dev NDM EXH"
172.29.4.108    wduwas0104 #COMMENT:"DM Dev ENGINE EXH"
172.29.4.109    wpuwas0101 #COMMENT:"DM PROD SERVICE HS" http://wpuwas0101:80/ badhttp:2:2:2
172.29.4.112    wpuwas0201 #COMMENT:"DM PROD NDM EXH" 
172.29.4.113    wpuwas0202 #COMMENT:"DM PROD SERVICE EXH" http://wpuwas0202:80/ badhttp:2:2:2
172.29.4.114    wpuwas0203 #COMMENT:"DM PROD ENGINE EXH" 
172.29.4.110    wpujra0201 #COMMENT:"PROD JIRA/Confluence" 
172.29.4.115	wdupcs0201 #COMMENT:"DEV/TEST EIP BUILD SERVER"
10.52.96.41	sxuebd0201 #COMMENT:"IPUP Build Slave"
#10.52.96.86	spubbs0201 #COMMENT:"WAS re-platform Production Linux Server"
##10.52.96.87	spwbts0201 #COMMENT:"WAS re-platform Production Windows Server" # SR #S123214

subpage vSphere5 vSphere5 Systems

group-compress vSphere5-Core
10.56.3.10 spwvcs0101
10.56.2.10 spwvcs0201
172.20.5.91 spupup0201
## 172.20.5.89 wpulog0201      S120182

group-compress vSphere5-Misc
10.30.5.249 tauwdm0101
10.30.5.178 ttuwdm0101
10.51.0.233 wpwapr0101 #COMMENT:"APRS"

group-compress vSphere5-SAS
10.30.5.21 tpusas0102
10.30.5.22 tpusas0103

group-compress vSphere5-IDM-Non-Prod
172.29.4.34 wduidv0201
172.29.4.35 wduidv0202
172.29.4.36 wduent0201
172.29.4.38 wduent0202
172.29.4.39 wduidu0201
172.29.4.40 wtuidv0201
172.29.4.45 wtuent0201
172.29.4.46 wtuent0202
172.29.4.48 wtuidu0201
172.29.4.50 wtuidv0101
172.29.4.51 wtuidu0101
172.29.4.52 wtuent0101

group-compress vSphere5-IDM-Prod
172.29.4.86 wpuent0102
172.29.4.89 wpuent0103
172.29.4.88 wpuent0201
172.29.4.85 wpuent0202
172.29.4.87 wpuent0203
172.29.4.90 wpuent0204
172.29.4.95 wpuidu0101
172.29.4.94 wpuidu0201
172.29.4.84 wpuidv0101
172.29.4.83 wpuidv0201

group-compress Aurion10.3-Non-Prod
172.29.4.174 tduaur0101 # COMMENT:"TAC Aurion 10.3 - DEV"  http://tduaur0101.services.workcover.vic.gov.au:8080/aurtacdev/ badhttp:2:2:2
172.29.4.175 wduaur0101 # COMMENT:"WSV Aurion 10.3 - DEV" http://wduaur0101.services.workcover.vic.gov.au:8080/aurdev/ badhttp:2:2:2
172.29.4.176 ttuaur0101 # COMMENT:"TAC Aurion 10.3 - Test"  http://ttuaur0101.services.workcover.vic.gov.au:8080/aurtactest/ badhttp:2:2:2
172.29.4.177 wtuaur0101 # COMMENT:"WSV Aurion 10.3 - Test" http://wtuaur0101.services.workcover.vic.gov.au:8080/aurtest/ badhttp:2:2:2
172.29.4.162 teuaur0101 # COMMENT:"TAC Aurion 10.3 - Training"  http://teuaur0101.services.workcover.vic.gov.au:8080/aurtactrain/ badhttp:2:2:2
172.29.4.161 weuaur0101 # COMMENT:"WSV Aurion 10.3 - Training" http://weuaur0101.services.workcover.vic.gov.au:8080/aurtrain/ badhttp:2:2:2

group-compress Aurion10.3-Prod
172.29.3.196 tpuaur0201 # COMMENT:"TAC Aurion 10.3 - Prod" http://tpuaur0201.services.workcover.vic.gov.au:8080/aurtacprod/ badhttp:2:2:2
172.29.3.195 wpuaur0201 # COMMENT:"WSV Aurion 10.3 - Prod" http://wpuaur0201.services.workcover.vic.gov.au:8080/aurprod/ badhttp:2:2:2

group-compress Atlassian-Confluence-JIRA-Servers
10.51.0.172 spujra0101 # COMMENT:"Prod Wiki/Jira Server" - Request S106933


include bb-hosts_devops.inc
include bb-hosts_edrms.inc
#group-compress vSphere5-EDRMS-Non-Prod
#172.29.4.150 ldbedrmswastst # COMMENT:"load balancer VIP for WAS - TEST" http://ldbedrmswastst.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2
#172.29.4.151 ldbedrmspetst # COMMENT:"load balancer VIP for PE - TEST" http://ldbedrmspetst.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.138 wdudms0101 # COMMENT:"FileNet CE/PE/UI 1 - DEV" http://wdudms0101.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2 http://wdudms0101.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
##172.29.4.138 wdudms0101 # COMMENT:"FileNet CE/PE/UI 1 - DEV"
#172.29.4.139 wdudms0102 # COMMENT:"FileNet CSS/ICM 1 - DEV"
#172.29.4.140 wdwdms0101 # COMMENT:"FileNet ICC/RE 1 - DEV"
#172.29.4.141 wtudms0101 # COMMENT:"FileNet CE/PE/UI 1 - TEST" http://wtudms0101.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2 http://wtudms0101.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
##172.29.4.139 wdudms0102 # COMMENT:"FileNet Content Engine - DEV" http://wdudms0102.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2 http://wdudms0102.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.142 wtudms0102 # COMMENT:"FileNet CE/PE/UI 2 - TEST" http://wtudms0102.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2 http://wtudms0102.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.143 wtudms0103 # COMMENT:"FileNet CSS/ICM 1 - TEST"
#172.29.4.144 wtwdms0101 # COMMENT:"FileNet ICC/RE 1 - TEST"

#group-compress vSphere5-EDRMS-Prod
#172.29.4.147 ldbedrmswas # COMMENT:"load balancer VIP for WAS - PROD" http://ldbedrmswas.services.workcover.vic.gov.au badhttp:2:2:2
#172.29.4.146 ldbedrmsce # COMMENT:"load balancer VIP for CE - PROD" http://ldbedrmsce.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2
#172.29.4.145 ldbedrmspe # COMMENT:"load balancer VIP for PE - PROD" http://ldbedrmspe.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.59 wpudms0206 # COMMENT:"FileNet Dmgr - PROD"
#172.29.4.60 wpudms0201 # COMMENT:"FileNet PE 1 - PROD" http://wpudms0201.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.62 wpudms0101 # COMMENT:"FileNet PE 2 - PROD" http://wpudms0101.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.63 wpudms0202 # COMMENT:"FileNet CE 1 - PROD" http://wpudms0102.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2
#172.29.4.64 wpudms0102 # COMMENT:"FileNet CE 2 - PROD" http://wpudms0102.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2
#172.29.4.65 wpudms0203 # COMMENT:"FileNet UI 1 - PROD"
#172.29.4.67 wpudms0103 # COMMENT:"FileNet UI 2 - PROD"
#172.29.4.69 wpudms0204 # COMMENT:"FileNet CSS 1 - PROD"
#172.29.4.70 wpudms0104 # COMMENT:"FileNet CSS 2 - PROD"
#172.29.4.71 wpudms0205 # COMMENT:"FileNet ICM 1 - PROD"
#172.29.4.72 wpwdms0201 # COMMENT:"FileNet ICC 1 - PROD" 
#172.29.4.73 wpwdms0202 # COMMENT:"FileNet RE 1 - PROD"

#group-compress vSphere5-EDRMS-PAT
#172.29.4.117 ldbedrmscepat # COMMENT:"load balancer VIP for CE - PAT" http://ldbedrmscepat.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2
#172.29.4.116 ldbedrmspepat # COMMENT:"load balancer VIP for PE - PAT" http://ldbedrmspepat.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.118 ldbedrmswaspat # COMMENT:"load balancer VIP for WAS - PAT" http://ldbedrmswaspat.services.workcover.vic.gov.au badhttp:2:2:2
#172.29.4.11 waudms0106 # COMMENT:"FileNet Dmgr - PAT"
#172.29.4.13 waudms0101 # COMMENT:"FileNet PE 1 - PAT" http://waudms0101.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.15 waudms0201 # COMMENT:"FileNet PE 2 - PAT" http://waudms0201.services.workcover.vic.gov.au:32776/IOR/ping badhttp:2:2:2
#172.29.4.23 waudms0102 # COMMENT:"FileNet CE 1 - PAT" http://waudms0102.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2 
#172.29.4.28 waudms0202 # COMMENT:"FileNet CE 2 - PAT" http://waudms0202.services.workcover.vic.gov.au/FileNet/Engine badhttp:2:2:2
#172.29.4.29 waudms0103 # COMMENT:"FileNet UI 1 - PAT"
#172.29.4.31 waudms0203 # COMMENT:"FileNet UI 2 - PAT"
#172.29.4.32 waudms0104 # COMMENT:"FileNet CSS 1 - PAT"
#172.29.4.96 waudms0204 # COMMENT:"FileNet CSS 2 - PAT"
#172.29.4.97 waudms0105 # COMMENT:"FileNet CC 1 - PAT"
#172.29.4.98 wawdms0101 # COMMENT:"FileNet ICC 1 - PAT"
#172.29.4.54 wawdms0102 # COMMENT:"FileNet RE 1 - PAT"

include bb-hosts_vsphere5.inc
include bb-hosts_ipup.inc
include bb-hosts_cbm.inc
include bb-hosts_warp_qas.inc

group-compress vSphere5-Avanti-Non-Prod
10.57.130.119 tduffo0102
10.57.130.120 tduffo0103
10.57.130.30 tcuffo0101
10.57.130.32 tcunfs0101
10.57.130.35 tduffo0101
10.57.130.47 ttuffo0109 
10.57.130.48 ttufbo0108 
10.57.130.50 ttumqs0103 
10.57.130.51 ttuffo0110 
10.57.130.52 ttufbo0109 
10.57.130.54 ttuffo0111 
10.57.130.55 ttufbo0110 
10.57.130.57 ttuffo0112 
10.57.130.130 ttufbo0111 
10.57.130.132 ttumqs0104 
10.57.130.133 ttuffo0113 
10.57.130.134 ttufbo0112 
10.57.130.136 ttumqs0105 
10.57.130.82 ttufbo0102
10.57.130.83 ttufbo0103
10.57.130.107 ttufbo0104
10.57.130.108 ttufbo0105
10.57.130.113 ttufbo0106
10.57.130.114 ttufbo0107
10.57.130.80 ttuffo0103
10.57.130.81 ttuffo0104
10.57.130.105 ttuffo0105
10.57.130.106 ttuffo0106
10.57.130.111 ttuffo0107
10.57.130.112 ttuffo0108
10.57.130.86 ttumqs0102
10.30.5.169 ttuffo0101
10.30.5.170 ttuffo0102
10.30.5.171 ttuffo0201
10.30.5.172 ttuffo0202
10.30.5.173 ttufbo0101
10.30.5.174 ttufbo0201
10.30.5.175 ttwdoc0101
10.30.5.176 ttwdoc0201
10.30.5.177 ttumqs0101
#10.30.5.179 ttwmlg0101

group-compress vSphere5-Avanti-Prod
#10.30.5.93 tpuwem0101 #COMMENT:"APM MOM" # WR S115573 - 08-04-2016
#10.30.5.94 tpuwac0101 #COMMENT:"APM Agent Collector - HAN" # WR S115573 - 08-04-2016
#10.30.5.95 tpuwac0201 #COMMENT:"APM Agent Collector - EXH" # WR S115573 - 08-04-2016
10.30.5.111 tpufbo0201 #COMMENT:"Fineos Back Office"
10.30.5.14 tpuffo0101 #COMMENT:"Fineos Front Office"
10.30.5.15 tpuffo0102 #COMMENT:"Fineos Front Office"
10.30.5.16 tpuffo0201 #COMMENT:"Fineos Front Office"
10.30.5.17 tpuffo0202 #COMMENT:"Fineos Front Office"
10.30.5.244 taufbo0101 #COMMENT:"Fineos Back Office"
10.30.5.245 taufbo0102 #COMMENT:"Fineos Back Office"
10.30.5.242 tauffo0101 #COMMENT:"Fineos Front Office"
10.30.5.243 tauffo0102 #COMMENT:"Fineos Front Office"
10.30.5.18 tpufbo0101 #COMMENT:"Fineos Back Office"
10.30.5.27 tpumqs0101 #COMMENT:"MQ Server"
10.30.5.248 taumqs0101 #COMMENT:"MQ Server"
10.30.5.102 tpuwdm0101 #COMMENT:"WebSphere Deployment Manager"

group-compress Sentinel Systems
10.56.130.22 spusen0201 # COMMENT:"Sentinel Prod Server"
10.56.130.23 sdusen0201 # COMMENT:"Sentinel Dev Server"

subpage Novus Novus Server
include bb-hosts_novus.inc

#group-compress Novus POTI Systems
#172.29.4.240	wduffo0201 # COMMENT:"POTI Front Office Server"
#172.29.?.?	wdwdoc0201 # COMMENT:"POTI Doc Prod Server"

#group-compress Novus TESTA Systems
#10.51.32.31 wtufbo0101 # COMMENT:"Fineos Back Office"
#10.51.32.41 wtufbo0102 # COMMENT:"Fineos Back Office"
#10.51.32.30 wtuffo0104 # COMMENT:"Fineos Front Office"
#10.51.32.40 wtuffo0105 # COMMENT:"Fineos Front Office"
#10.51.32.32 wtwdoc0104 # COMMENT:"Doc Prod Server"
#10.51.32.42 wtwdoc0105 # COMMENT:"Doc Prod Server"
#10.52.96.23 wtundm0101 # COMMENT:"WebSphere Deployment Manager"

#group-compress Novus SVT Systems
#10.51.32.43 wtuffo0202 # COMMENT:"Fineos Front Office"
#10.51.32.44 wtuffo0203 # COMMENT:"Fineos Front Office"
#10.51.32.45 wtuffo0109 # COMMENT:"Fineos Front Office"
#10.51.32.46 wtuffo0110 # COMMENT:"Fineos Front Office"
#10.51.32.47 wtufbo0201 # COMMENT:"Fineos Back Office"
#10.51.32.48 wtufbo0105 # COMMENT:"Fineos Back Office"
#10.51.32.33 wtwdoc0202 # COMMENT:"Doc Prod Server"
#10.51.32.34 wtwdoc0109 # COMMENT:"Doc Prod Server"
#10.52.96.22 wtundm0201 # COMMENT:"WebSphere Deployment Manager"
#10.51.32.35 wtwrsu0201 # COMMENT:"RSU Server"

#group-compress Novus PAT Systems
#10.51.0.40 wauffo0201 # COMMENT:"Fineos Front Office"
#10.51.0.41 wauffo0202 # COMMENT:"Fineos Front Office"
#10.51.0.42 waufbo0201 # COMMENT:"Fineos Back Office"
#10.51.0.43 waufbo0202 # COMMENT:"Fineos Back Office"
#10.51.0.44 wawdoc0201 # COMMENT:"Doc Prod Server"
#10.51.0.45 wawdoc0202 # COMMENT:"Doc Prod Server"
#10.51.0.46 wawrsu0201 # COMMENT:"RSU Server"
#10.52.96.29 waundm0201 # COMMENT:"WebSphere Deployment Manager"

subpage Splunk Splunk Server
include bb-hosts_splunk.inc

subpage ALC ALC Systems

group-compress ALC Systems
172.20.5.76     alc0076  # COMMENT:"Connect Direct SG cluster - EXH" DESCR:"Linux SG Cluster:Production EXH"
172.20.5.77     alc0077  # COMMENT:"Connect Direct SG cluster - EXH" DESCR:"Linux SG Cluster:Production EXH"
172.20.5.61	vwacd061 # COMMENT:"Connect Direct SG Package"
172.20.5.79     alc0079  # COMMENT:"Connect Direct SG cluster DR - HAN" DESCR:"Linux SG Cluster:DR Hansen"
172.20.5.62	vwacd061dr # COMMENT:"Connect Direct DR SG Package"
10.51.2.21	wpucdt0101 # COMMENT:"New Connect Direct Production server"

subpage BSL BSL Systems
dispinclude user_hosts/bsl-hosts

group-compress BSL Systems
#172.29.2.73	bsl0073  # COMMENT:"HAN" 
#172.29.2.78    bsl0078  # COMMENT:"HAN" 
#172.29.2.89     bsl0089  # COMMENT:"Xymon Server"

subpage OracleDB Oracle DBs
include bb-hosts_oradb.inc

#group-compress Oracle DR Databases
#172.29.3.235    paurdr   # COMMENT:"DR PAUR PKG on orae112-th" DESCR:"Oracle(EE):New PROD Aurion DR"
#172.29.2.193    pcamdr   # COMMENT:"DR PCAM PKG on orae112-th" DESCR:"Oracle(EE):ProdDB-prmy for Case Administration Mana DR"
#172.29.2.183    pdwrdr   # COMMENT:"DR PDWR PKG on orae112-th" DESCR:"Oracle(EE):ProdDB-prmy for partial replica of PDWH DR"
#172.29.2.175    plnrdr   # COMMENT:"DR PLNR PKG on orae112-th" DESCR:"Oracle(EE):Production(Primary) Licensing and registration DR"
#172.29.2.182    psmldr   # COMMENT:"DR PSML PKG on orae112-th" DESCR:"Oracle(EE):ProdDB for small apps (PGRLNOTESCASEFLOW DR"
#172.29.3.79     pwpsdr   # COMMENT:"DR PWPS PKG on orae112-th" DESCR:"Oracle(EE):PROD env for IMPL(foundation) for WF/CS DR"
#172.29.3.136    rcatdr   # COMMENT:"DR RCAT PKG on orae112-th" DESCR:"Oracle(EE):New PROD RMAN catalog DR"
#172.29.2.146    ptacadr  # COMMENT:"DR PTACA PKG on orae112-th" DESCR:"ProdDB-stdby TAC-Production version of aurion"
#172.29.3.53     psm4dr   # COMMENT:"DR PSM4 PKG on orae112-th" DESCR:"Oracle(EE):ProdDB-stdby for apps(eWFM,ELs,TPC)"
#172.29.2.52     pfs2dr   # COMMENT:"DR PFS2 PKG on orae112-th" DESCR:"Oracle(EE):ProdDB-stdby Fieldlink, SSCM"
#172.29.2.155    rcamdr   # COMMENT:"DR RCAM PKG on orae112-th" DESCR:"Oralce(EE):ProdDB-stdby Reporting database for ABR, Cams, FMS and Assyst"
##172.20.5.83     psm2dr   # COMMENT:"DR PSM2 PKG on oras116-th" DESCR:"Oracle(SE):ProdDB-stdby db2 for small apps (First Library,Pace,TestDir)"
#172.29.3.194	ppcscdr # COMMENT:"PROD PCS PKG on orae112-exh" DESCR:"Oracle(EE): PCS CONFIG DR DB"
#172.29.3.191	ppcstdr # COMMENT:"PROD PCS PKG on orae112-exh" DESCR:"Oracle(EE): PCS DR TRANSACTION DB"
#172.29.3.226	pdwr2dr	# COMMENT:"PROD PCS PKG on orae112-exh" DESCR:"ProdDB-prmy 2 for partial replica of PDWH"


subpage FIN Finance Systems

group-compress Finance Systems
172.20.5.101     fin0101  # DESCR:"Linux Finance SG Cluster:Production 222"
172.20.5.102     fin0102  # DESCR:"Linux Finance SG Cluster:Production 222"
172.20.5.103     fin0103  # COMMENT:"HAN" DESCR:"Linux Finance SG Cluster:TestDev 222"
172.20.5.104     fin0104  # COMMENT:"HAN" DESCR:"Linux Finance SG Cluster:TestDev 222"

# New Oracle Financials - 15/03/2016
group-compress Oracle Financials
10.51.32.245    wdufin0201 #COMMENT:"Oracle Financials Development"
10.51.32.154    wtufin0201 #COMMENT:"Oracle Financials Test"
10.51.32.244    wuufin0201 #COMMENT:"Oracle Financials UAT"
10.51.0.234     wpufin0101 #COMMENT:"Oracle Financials Production"

subpage NAM NAM Systems (View)
include bb-hosts_nam.inc

subpage ORACLE Oracle Systems (View)
dispinclude user_hosts/oracle-hosts

subpage NFS NFS services (View)
172.29.2.107    eipprodnfs #COMMENT:"EIP Prod NFS SG Package" DESCR:NFS:"NFS4 service hosted on linvm143/144"
172.29.4.21     eippatnfs  #COMMENT:"EIP PAT NFS SG Package" DESCR:NFS:"NFS4 service hosted on linv4014/4016"
172.29.3.89     nfscluster #COMMENT:"EIP Non-Prod NFS - RHCS" DESCR:NFS:"NFS4 service hosted on linv3039/3071"
172.29.2.21     prodnfs    #COMMENT:"Prod NFS - RHCS" DESCR:NFS:"NFS4 service hosted on linvm128/129"

subpage MQ MQ Services

group-compress MQ Services
172.28.4.109    eipprodmq01 #COMMENT:"EIP PROD MQ Package"
192.168.224.111 eipprodmbrad01 # COMMENT:"EIP PROD WMB RAD MQ Package"

subpage NETAPP NetApp MGMT Servers

group-compress NetApp MGMT Servers
172.20.5.4	SPWCVS0201 	# COMMENT:"Exhibition SnapProtect"
172.20.5.232	SPWCVM0201 	# COMMENT:"Exhibition Media Server"
172.20.5.235	SPWCVM0101 	# COMMENT:"Hansen Media server
172.20.5.44	SPWVSA0101 	# COMMENT:"Hansen Virtual Storage agent"
172.20.5.45	SPWVSA0201 	# COMMENT:"Exhibition Virtual Storage agent"
172.20.3.217	SPWOCC0201 	# COMMENT:"Exhibition OnCommand Core"
172.20.5.233	SPWOCI0201 	# COMMENT:"Exhibition OnCommand Insight"
172.20.5.2	SPWSAV0201 	# COMMENT:"Exhibition Symantec Antivirus"
172.20.5.3	SPWSAV0202 	# COMMENT:"Exhibition Symantec Antivirus"
172.20.5.6	SPWSAV0101 	# COMMENT:"Hansen Symantec Antivirus"
172.20.5.7	SPWSAV0102 	# COMMENT:"Hansen Symantec Antivirus"

# New TRIM servers S71846
subpage TRIM  TRIM Servers
include bb-hosts_trim.inc


subpage pClass P Class Server (View)
dispinclude user_hosts/pclass-hosts

subpage Assyst-V10 Assyst V10 Servers (View)

group-compress Assyst V10 Production Servers
10.51.0.224   spwsca0101 # COMMENT:"Prod Assyst V10 Application Server"
10.51.0.225   spwsca0201 # COMMENT:"Prod Assyst V10 Application Server"
10.51.0.226   spwsci0101 # COMMENT:"Prod Assyst V10 Integration Server"
10.51.0.227   spwsci0201 # COMMENT:"Prod Assyst V10 Integration Server"
10.51.0.228   spwscr0101 # COMMENT:"Prod Assyst V10 Reporting Server"

group-compress Assyst V10 Test Servers
10.51.32.142  stwsca0101 # COMMENT:"Test Assyst V10 Application Server"
10.51.32.143  stwsca0201 # COMMENT:"Test Assyst V10 Application Server"
10.51.32.144  stwsci0101 # COMMENT:"Test Assyst V10 Integration Server"
10.51.32.145  stwsci0201 # COMMENT:"Test Assyst V10 Integration Server"
10.51.32.146  stwscr0101 # COMMENT:"Test Assyst V10 Reporting Server"

group-compress Assyst V10 Dev Servers
10.51.32.147  sdwsca0201 # COMMENT:"Dev Assyst V10 Application Server"
10.51.32.148  sdwsci0201 # COMMENT:"Dev Assyst V10 Integration Server"
10.51.32.149  sdwscr0201 # COMMENT:"Dev Assyst V10 Reporting Server"

subpage P2P-Servers P2P Servers (View)

group-compress P2P Production Servers
10.51.0.237   wpwppa0101 # COMMENT:"Prod P2P Application Server"
10.51.0.238   wpwppw0101 # COMMENT:"Prod P2P WebServer Server"

group-compress P2P Test Servers
10.51.33.206  wtwppa0201 # COMMENT:"Test P2P Application Server"
10.51.33.207  wtwppw0201 # COMMENT:"Test P2P WebServer Server"

group-compress P2P Dev Servers
10.51.33.208  wdwppa0201 # COMMENT:"Dev P2P Application Server"
10.51.33.209  wdwppw0201 # COMMENT:"Dev P2P WebServer Server"

subpage WSV-VOICE WSV VOICE (View)

group-compress WSV Voice Production Servers
10.51.0.230    wpwqms0201 # COMMENT:"WSV Prod Qmaster Server"
10.51.0.231    wpwiac0201 # COMMENT:"WSV Prod NEC IAC Console Server"
10.51.0.232    wpwpxm0201 # COMMENT:"WSV Prod MA4000 Server"

subpage WSV-Intranet WSV Intranet (View)

group-compress WSV Intranet Hosts
10.51.0.245     wpuwpp0101 #COMMENT:"WSV Intranet"
10.51.0.246     wpuwpp0201 #COMMENT:"WSV Intranet"
10.51.0.247     wpuwpa0102 #COMMENT:"WSV Intranet"
10.52.96.208    wpudmp0101 #COMMENT:"WSV Intranet"

subpage TAC-Intranet TAC Intranet (View)

group-compress TAC Intranet Hosts
10.51.0.242     tpuwpp0101 #COMMENT:"TAC Intranet"
10.51.0.243     tpuwpp0201 #COMMENT:"TAC Intranet"
10.51.0.244     tpuwpa0102 #COMMENT:"TAC Intranet"
10.52.96.206    tpudmp0101 #COMMENT:"TAC Intranet"

subpage Shared-Portal Shared Portal (View)

group-compress Shared Portal Hosts
10.51.0.248     spuwps0101 #COMMENT:"Shared Portal"
10.51.0.249     spuwps0201 #COMMENT:"Shared Portal"
10.52.96.204    spudmp0101 #COMMENT:"Shared Portal"

subpage Audio-Visual Audio Visual (View)

group-compress Audio Visual Hosts
10.51.1.10      spavcr0201 #COMMENT:"Audio Visual - Video Conferencing - Virtual Appliance"
10.51.1.11      spavcd0201 #COMMENT:"Audio Visual - Video Conferencing - Virtual Appliance"
10.51.1.15      spavcp0201 #COMMENT:"Audio Visual - Video Conferencing - Virtual Appliance"
10.50.0.79      spavcg0201 #COMMENT:"Audio Visual - Video Conferencing - Virtual Appliance"
10.51.1.16      spavcb0201 #COMMENT:"Audio Visual - Video Conferencing - Hardware Appliance"

subpage BigFix-LMT BigFix LMT (View)

group-compress BigFix LMT Hosts
10.52.96.200    spwlmt0101 #COMMENT:"BigFix LMT"

subpage EPC-Servers EPC Servers (View)

group-compress EPC Servers
10.51.0.69      tpwbpm0101 #COMMENT:"EPC Server"
10.52.0.33      tpwbpm0102 #COMMENT:"EPC Server"



#subpage All Monitored Servers (View)
#dispinclude user_hosts/all-hosts

page Networks Network Services Team 

title Network Services Team

subpage WINDOWS-SERVERS Windows Servers

group-compress Windows Servers
##172.29.2.230	apex0011 # COMMENT:"CASE"
##172.29.2.231	apex0012 # COMMENT:"CASE - Prod HAN"
##172.20.2.37     ho13clu2 # http://ho13clu2.services.workcover.vic.gov.au notes-port:1352:s:q COMMENT:"wpwdom0126"
172.29.2.86     wpwdom0228 # COMMENT:"Domino iNote Primary Mail Server"
172.29.2.37     wpwdom0128 # COMMENT:"Domino iNotes Secondary Mail Server"
# 172.20.3.108    wpwdom0210 # COMMENT:"Domino Mail Primary mail Server"
# 172.20.3.107	melbms8 # COMMENT:"Media Server"
172.20.3.77	melapl1 # COMMENT:"Actuarial"
# 172.20.3.120 	melarc120 # COMMENT:"Notes email archive" 
#172.20.3.28     melbms9 # COMMENT:"Mail - DR"
203.5.13.167    melcap1 # COMMENT:"Call Accounting"
#172.20.3.30     meldap1 # COMMENT:"Fieldlink"
#172.20.3.129    winvmhoadm # notes-port:1352:s:q http://hoadmin.vwa.gov.au/ badhttp:2:2:2 COMMENT:"Dom Admin"
#172.20.3.46     meldap2 # COMMENT:"Fieldlink - DR" # Removed from Xymon monitoring per incident #550968 from Vahid Goga
##172.20.3.42     meldc01 # COMMENT:"AD DC1"  # Removed S67864
##172.20.3.45     meldc02 # COMMENT:"AD DC2"
##172.20.3.44     meldc03 # COMMENT:"AD DC3"
###172.29.2.24	meldex1	# notes-port:1352:s:q http://agentonline/ badhttp:2:2:2 badnotes-port:2:2:2 COMMENT:"Portal Apps"
###172.29.2.24	meldex1-apex0017	# notes-port:1352:s:q http://agentonline/ badhttp:2:2:2 badnotes-port:2:2:2 COMMENT:"Portal Apps"
###172.20.3.7	melds1  # COMMENT:"Dom Apps"
###172.20.3.73	melds3  # COMMENT:"Internal QPs"
###172.20.3.7      intranet # COMMENT:"melds1" http://intranet.workcover.vic.gov.au/ notes-port:1352:s:q badhttp:2:2:2
##172.20.3.50	melds1-ho1  # COMMENT:"Dom Apps"
##172.20.3.15     winvmds15-HO1CLU2  # notes-port:1352:s:q http://ho1clu2.vwa.gov.au/ badhttp:2:2:2 COMMENT:"Internal Apps - DR"
##172.20.3.18     melems1 # COMMENT:"Environment Mgr"
172.25.128.10     spwems0201 # COMMENT:"Environment Mgr"
#192.168.223.30  melips1 # COMMENT:"Intrusion PS" # Removed on 05/11/2015 - Requested by Sam Sari
203.6.223.34    wpwdom0222 # smtp:s:q notes-port:1352:s:q COMMENT:"MailGW"
203.6.223.37    wpwdom0223 # (Domino DMZ Web Cluster server 1) COMMENT:"Dmz Web01" 
203.6.223.44    wpwdom0122 # smtp:s:q notes-port:1352:s:q COMMENT:"MailGW - DR"
203.6.223.47    wpwdom0123 # (WEB01clu2 - Domino DMZ Web Cluster server 2 ) COMMENT:"Dmz Web02" 
#172.20.3.25	melmia1  # COMMENT:"MiAudio"
172.20.3.188    melpvm1    # COMMENT:"VoiceMail1"
#172.20.3.189    melpvm2    # COMMENT:"VoiceMail2"
172.20.3.91	winvmpvm91 # COMMENT:"Voice Matt4000 Server"
172.20.3.12     melqm1    # COMMENT:"QMaster"
##172.29.2.152	melrm152   # COMMENT:"Risk Mgmt"
#172.20.3.157	melrev157 # COMMENT:"Call recording and Evaluation" #S114741 - 14/04/2016
#172.29.3.105	winvmsas105  # COMMENT:"SAS Dev App Server"
172.20.3.52     melsma1    # COMMENT:"SAN Mgr sm-eva - EXH"
172.20.3.26     melsma2    # COMMENT:"SAN Mgr CA-eva-pair - HAN"
#172.20.3.23     meltrm01   # COMMENT:"Trim"
#172.20.3.49     meltrm1    # COMMENT:"Trim - HAN"
#172.29.2.55     melvms2    # COMMENT:"VM Portaltest"
#172.20.3.161	melwfm161 # COMMENT:"eWFM App"
172.20.3.162	melwfm162 # COMMENT:"eWFM Analyze"
10.56.138.29	wpwwfm0203	# COMMENT:"WFM server"
##172.20.3.76     melznpm1   # COMMENT:"Patch Mgmt" #Removed R41059 
#203.6.220.124	mulqm01    # COMMENT:"Mulgrave QMaster Server"
#192.168.13.10	mulqm01    # COMMENT:"Mulgrave QMaster Server" #S114741 - 14/04/2016
#192.168.17.8	essqm01	   # COMMENT:"Essendon Fields QMaster Server" #S114741 - 14/04/2016
#192.168.222.48  PWMGR      # COMMENT:"iChain Password Mgr"
#172.29.2.91     reprint    # COMMENT:"Doc Reprinting"
##172.20.3.138    soemanager #
##172.29.3.120    winino120 #  COMMENT:"iNotes Server"
##172.29.3.121    winino121 #  COMMENT:"iNotes-DR"
172.20.3.82	winsame82  # COMMENT:"Domino Sametime"
172.20.3.83	winsma1	   # COMMENT:"HP SIM"
#172.20.3.89     winvc89 #COMMENT:"VC-HAN"
#172.20.3.34     winvmadi34 # COMMENT:"Oracle ADI Reporting Svr"
###172.29.3.213    winvmadobe213 #
0.0.0.0         blackberry # noconn COMMENT:"Blackberry Services"
#172.20.3.55     winvmbb55HA #  COMMENT:"Blackberry" notes-port:1352:s:q badnotes-port:2:2:2
#172.20.3.155    winvmbb55mgt1 # COMMENT:"BB MGT IP Primary"
#172.20.3.156    winvmbb55mgt2 # COMMENT:"BB MGT IP Secondary"
172.20.3.171    winvmca1  # COMMENT:"W C Server Primary
172.20.3.172    winvmca2  # COMMENT:"W C Server Secondary
172.29.2.72	winvmds72 # COMMENT:"Domino Mail Server"
# 172.20.3.60 	winvmcf60 # COMMENT:"CaseFlow Mail"
# 172.20.3.64	winvmcp64 #
172.20.3.142	winvmdoor142 # COMMENT:"Requirements Manager"
# 172.20.3.140    winvmlei1 # COMMENT:"LEI Server"
# 172.20.3.199    winvmlei2 # COMMENT:"LEI2 Server"
#172.20.3.51	winvmpm51 # COMMENT:"Process Mentor"
##172.20.3.36	winvmptrm36 # COMMENT:"TRIM PROD-EXH"
172.20.3.53	winvmsmsprod53 # COMMENT:"PROD SMS Server EXH"
172.20.3.54	winvmsmsprod54 # COMMENT:"PROD SMS Server HAN"
172.20.3.165	winvmsms165 # COMMENT:"PROD SMS Server EXH"
172.20.3.166	winvmsms166 # COMMENT:"PROD SMS Server HAN"
172.20.3.168	winvmsmsuat168 # COMMENT:"UAT SMS Server EXH"
172.20.3.175	winvmsmsuat175 # COMMENT:"UAT SMS Server EXH"
172.20.3.92	winvmsmstrn92 # COMMENT:"Training SMS Server EXH"
#172.20.3.123    winvmveras123 #
#172.20.3.70     WPWBAS0201 # COMMENT:"P2P Prod App"
#172.20.3.71     WPWBAS0202 # COMMENT:"P2P Prod Web"
#172.20.3.224    WINVMBASADEV224 # COMMENT:"P2P DEV App"
# NEW DOMINO Servers S34309/S34640 : 5/7/2012
# 172.29.4.204    wpwdom0110 # COMMENT:"Domino Secondary Mail Server"
172.29.3.129    wpwdom0217 # COMMENT:"Domino Administration Hub - HOAdmin"
172.20.3.213    wdwdom0104 # COMMENT:"Domino Dev Servers"
172.29.4.191    wdwdom0105 # notes-port:1352:s:q badnotes-port:2:2:2 COMMENT:"Domino Dev Servers"
172.29.4.192    wdwdom0106 # notes-port:1352:s:q badnotes-port:2:2:2 COMMENT:"Domino Dev Servers"
172.20.3.214    wdwdom0107 # COMMENT:"Domino Dev Servers"
172.29.4.193    wdwdom0108 # COMMENT:"Domino Dev Servers"
172.20.3.215    wtwdom0104 # COMMENT:"Domino Test Servers"
172.29.4.194    wtwdom0105 # COMMENT:"Domino Test Servers"
172.29.4.195    wtwdom0106 # COMMENT:"Domino Test Servers"
172.20.3.216    wtwdom0107 # COMMENT:"Domino Test Servers"
172.29.4.196    wtwdom0108 # COMMENT:"Domino Test Servers"
172.20.3.82     wpwdom0229 # COMMENT:"HO9 - Domino Sametime Primary" 
172.20.3.112    wpwdom0213 # COMMENT:"Domino Archive Mail Server HO18"
172.20.3.227    wpwdom0121 # COMMENT:"Domino Sametime DR Server"
172.20.3.40     wpwdom0215 # COMMENT:"HO5 - Fieldlink Direct Access 1"
172.20.3.47     wpwdom0115 # COMMENT:"HO5clu2 - Fieldlink Direct Access 2"
172.20.3.19     wpwdom0218 # COMMENT:"HO11clu1 - LEI Primary"
172.20.3.139    wpwdom0118 # COMMENT:"HO11clu2 - LEI Secondary"
172.29.2.24     wpwdom0224 # COMMENT:"APEX0017 - Extranet Application Server 1"
172.29.2.33     wpwdom0124 # COMMENT:"APEX0017clu2 - Extranet Application Server 2"
172.20.3.48     wpwdom0116 # COMMENT:"HO15clu2 Fieldlink Inspectors Prim Sync"
172.20.3.41     wpwdom0216 # COMMENT:"HO15 Fieldlink Inspectors Sec Sync"
172.20.3.15     wpwdom0113 # COMMENT:"HO1clu2 Domino DR Hub Server"
172.20.3.7      wpwdom0227 # COMMENT:"HO1 Domino Hub Server"
172.20.3.9      wpwdom0214 # COMMENT:"HO7 Domino Quickr Server"
172.20.3.20     wpwdom0114 # COMMENT:"HO7clu2 Domino Quickr DR Server"
172.29.2.35     wpwdom0225 # COMMENT:"APEXDS19 Domino Extranet Quickr Server"
172.29.2.87     wpwdom0125 # COMMENT:"APEXDS19clu2 Domino Extranet Quickr DR Server"
#172.20.3.69 	WPWBES0201 # COMMENT:"Blackberry Primary Server"
#172.20.3.68     WPWBES0101 # COMMENT:"Blackberry Standby Server"
10.51.0.20	SPWWLA0201 # COMMENT:"Workload Automation Server Exhibition"
10.51.0.21	SPWWLA0102 # COMMENT:"Workload Automation Server Hansen 1"
# 10.51.32.80	SDWWLA0101 # COMMENT:"Workload Automation Server Hansen 2"
10.51.0.22	SPWFTP0201 # COMMENT:"Workload Automation Server FTP server Exhibition"
10.51.32.66	SDWFTP0101 # COMMENT:"Workload Automation Server FTP server Hansen"
10.51.0.236     wpunad0101 # COMMENT:"New Fieldlink Server" #S120119 on 09/06/2016


# S34519 Traveler servers
172.29.3.17     wpwdom0220 # COMMENT:"Traveler Primary"
172.29.3.19     wpwdom0120 # COMMENT:"Traveler Standby"
10.57.132.60    TPWFAX0201 # COMMENT:"Rightfax server"


# remove below - Dana - ITSS114141
#172.20.3.13    winvmmq13 # COMMENT:"MQ"

172.20.3.50     winvmmq50 # COMMENT:"MQ"
172.20.3.86     winvmmq86 # COMMENT:"MQ Broker Toolkit"
##172.20.3.20   winvmqp20 # COMMENT:"Internal QPs" notes-port:1352:s:q badnotes-port:2:2:2  http://winvmqp20.vwa.gov.au badhttp:2:2:2
##172.29.2.41     winvmqp41 # COMMENT:"Portal QPs"
#172.29.3.26     winvmssn026 #
#172.29.3.27     winvmssn027 # Removed from Xymon monitoring per incident #550968 from Vahid Goga
172.20.3.14     winvmut14 # COMMENT:"NS Server"
#172.20.3.125    winvmuxc125 #
###172.20.3.111    winvmqc111 # COMMENT:"Quality Center" - S116890 - 28/04/2016
###172.20.3.115    winvmqc115 # COMMENT:"Quality Center DEV" - S116890 - 28/04/2016
10.51.0.169     spwqcs0101 # COMMENT:"Quality Center Production"
10.51.32.36     sdwqcs0201 # COMMENT:"Quality Center Dev"
10.51.32.37     stwqcs0201 # COMMENT:"Quality Center Test"
172.20.3.130    winvmhud130 # COMMENT:"Hudson Windows Slave"
172.20.3.185    winvmhud185 # COMMENT:"Hudson Windows Slave"
172.29.3.131    winvmwebint131 # COMMENT:"WEB Integration"
#172.20.3.87    winvmvc87 # COMMENT:"VirtualCtr Mgr"
# 172.20.3.245    wpwham0201 # COMMENT:"HARDCAT DB Server"
#10.51.0.173     spwdor0101 # COMMENT:"Prod Telelogic DOORS Server"

subpage WINDOWS-SERVERS-NEW Windows Servers NEW
172.20.8.41	WPWDFS0201	# COMMENT:"Windows Branch Server Master"
192.168.222.36	WPWDAS0201	# COMMENT:"Windows Direct Access Server"
192.168.222.37	WPWDAS0101	# COMMENT:"Windows Direct Access Server"
172.20.8.15	WPWINF0101	# COMMENT:"Windows Domain Controller"
172.20.8.16	WPWINF0201	# COMMENT:"Windows Domain Controller"
172.20.8.17	WPWINF0202	# COMMENT:"Windows Domain Controller"
192.168.10.15	WPWINF1001	# COMMENT:"Windows Domain controller"
192.168.13.15	WPWINF1201	# COMMENT:"Windows Domain controller"
192.168.14.15	WPWINF1101	# COMMENT:"Windows Domain controller"
192.168.17.15	WPWINF0701	# COMMENT:"Windows Domain controller"
192.168.18.15	WPWINF0601	# COMMENT:"Windows Domain controller"
192.168.19.15	WPWINF0901	# COMMENT:"Windows Domain controller"
192.168.20.15	WPWINF0801	# COMMENT:"Windows Domain controller"
192.168.21.15	WPWINF0401	# COMMENT:"Windows Domain controller"
192.168.22.15	WPWINF1601	# COMMENT:"Windows Domain controller"
192.168.23.15	WPWINF1301	# COMMENT:"Windows Domain controller"
192.168.24.15	WPWINF1501	# COMMENT:"Windows Domain controller"
192.168.25.15	WPWINF1401	# COMMENT:"Windows Domain controller"
192.168.26.15	WPWINF0501	# COMMENT:"Windows Domain controller"
192.168.10.16	WPWFAP1001	# COMMENT:"Windows File and print server"
192.168.13.16	WPWFAP1201	# COMMENT:"Windows File and print server"
192.168.14.16	WPWFAP1101	# COMMENT:"Windows File and print server"
192.168.17.16	WPWFAP0701	# COMMENT:"Windows File and print server"
192.168.18.16	WPWFAP0601	# COMMENT:"Windows File and print server"
192.168.19.16	WPWFAP0901	# COMMENT:"Windows File and print server"
192.168.20.16	WPWFAP0801	# COMMENT:"Windows File and print server"
192.168.21.16	WPWFAP0401	# COMMENT:"Windows File and print server"
192.168.22.16	WPWFAP1601	# COMMENT:"Windows File and print server"
192.168.23.16	WPWFAP1301	# COMMENT:"Windows File and print server"
192.168.24.16	WPWFAP1501	# COMMENT:"Windows File and print server"
192.168.25.16	WPWFAP1401	# COMMENT:"Windows File and print server"
192.168.26.16	WPWFAP0501	# COMMENT:"Windows  File and print server"
172.20.8.40	WPWPRN0201	# COMMENT:"Windows Head Office Print Services"
10.57.130.15	WDWINF0101	# COMMENT:"Windows Domain Controller"
172.20.8.26	WPWMDT0101	# COMMENT:"Windows MDT server"
172.20.8.25	SPWSCM0101	# COMMENT:"Windows SCCM server"
172.20.8.20	WPWSQL0201	# COMMENT:"Windows SQL server"
172.20.8.19	WPWUTL0201	# COMMENT:"Windows Utility server"
172.20.18.23	WTWCER0201	# COMMENT:"Windows Certificate Server"
172.20.18.24	WTWCER0101	# COMMENT:"Windows Certificate Server"
#192.168.222.212 	STWCAG0201	# COMMENT:"Windows	Citrix NetScaler"
#192.168.222.61	STWCAG0101	# COMMENT:"Windows Citrix NetScaler"
10.57.131.32	STWCWI0101	# COMMENT:"Windows Citrix Web Interface Server"
172.20.18.32	STWCWI0201	# COMMENT:"Windows Citrix Web Interface Server"
172.20.18.30	WTWXAS0201	# COMMENT:"Windows Citrix XenApp Server (Farm)"
172.20.18.31	WTWXAS0101	# COMMENT:"Windows Citrix XenApp Server (Farm)"
172.20.18.43	WTWFIL0201	# COMMENT:"Windows DFS Replica"
# 192.168.222.203	WTWDAS0201	# COMMENT:"Windows Direct Access Server	"
# 192.168.222.204	WTWDAS0101	# COMMENT:"Windows Direct Access Server	"
172.20.18.15	WTWINF0201	# COMMENT:"Windows Domain Controller"
172.20.10.130	WTWINF0101	# COMMENT:"Windows Domain Controller"
172.20.18.26	WTWMDT0101	# COMMENT:"Windows MD"
172.20.18.41	WTSFIL0201	# COMMENT:"Windows NetApp Filer"
172.20.18.40	WTWPRN0201	# COMMENT:"Windows Print / FTP Server"
172.20.18.25	STWSCM0101	# COMMENT:"Windows SCCM 2012"
172.20.18.20	WTWSQL0201	# COMMENT:"Windows SQL Server"
172.20.18.19	WTWUTL0201	# COMMENT:"Windows Utility Server"
# 172.20.18.10	WTWMIG0201	# COMMENT:"Windows Windows Migration Server"#IR555337 - Decommissioned
10.57.130.16	WDWINF0201	# COMMENT:"Windows Domain Controller"
172.20.19.27	WDWMDT0101	# COMMENT:"Windows MDT"
172.20.19.40	WDWPRN0201	# COMMENT:"Windows Print / FTP Server"
172.20.19.20	WDWSQL0201	# COMMENT:"Windows SQL Server"
172.20.19.19	WDWUTL0201	# COMMENT:"Windows Utility Server"
172.20.19.25	SDWSCM0101	# COMMENT:"Windows SCCM "


WINDOWS-TAC TRIM SERVERS-NEW Windows Servers NEW

 Domino TAC new servers
10.57.130.61    TPWDAD0101      #COMMENT:"Domino Admin Server"
10.30.5.56      SVRMN1MAIL      #COMMENT:"Domino Mail #1 (Mail Cluster)"
10.30.5.30      SVRMN2MAIL      #COMMENT:"Domino Mail #2 (Mail Cluster)"
10.57.130.64    TPWDAR0101      #COMMENT:"Domino Mail Archive Server"
10.30.5.79      SVRMN2HUB       #COMMENT:"Domino LDAP #1 (LDAP Cluster)"
10.30.5.100     SVRMN3HUB       #COMMENT:"Domino LDAP #2 (LDAP Cluster)"
10.57.130.67    TPWDAP0201      #COMMENT:"Domino Application #1 (Appl Cluster)"
10.30.5.69      SVRMN2APPS      #COMMENT:"Domino Application #2 (Appl Cluster)"
10.30.5.114     SVRMN3APPS      #COMMENT:"Domino eFile #1 (eFile Cluster)"
10.30.5.117     SVRMN4APPS      #COMMENT:"Domino eFile #2 (eFile Cluster)"
10.30.5.58      INTMN1WEB       #COMMENT:"Domino Web #1 (Web Cluster)"
10.57.130.72    TPWDWB0201      #COMMENT:"Domino Web #2 (Web Cluster)"
10.57.130.33    TTWDAP0101      #COMMENT:"Domino Training Server"
10.57.130.37	TSWDML0101	"COMMENT:SVT Domino Mail #1 (Mail Cluster)"
10.57.130.100	TSWDML0201	"COMMENT:SVT Domino Mail #2 (Mail Cluster)"
10.57.130.38	TSWDLD0101	"COMMENT:SVT Domino LDAP #1 (LDAP Cluster)"
10.57.130.101	TSWDLD0201	"COMMENT:SVT Domino LDAP #2 (LDAP Cluster)"
10.57.130.39	TSWDAP0101	"COMMENT:SVT Domino Application #1 (Appl Cluster)"
10.57.130.102	TSWDAP0201	"COMMENT:SVT Domino Application #2 (Appl Cluster)"
10.57.130.40	TSWDEF0101	"COMMENT:SVT Domino eFile #1 (eFile Cluster)"
10.57.130.103	TSWDEF0201	"COMMENT:SVT Domino eFile #2 (eFile Cluster)"
10.57.130.41	TSWDWB0101	"COMMENT:SVT Domino Web #1 (Web Cluster)"
10.57.130.104	TSWDWB0201	"COMMENT:SVT Domino Web #2 (Web Cluster)"
10.57.130.22	TDWDML0101	"COMMENT:DEV Domino Mail Server"
10.57.130.23	TDWDLD0101	"COMMENT:DEV Domino LDAP Server"
10.57.130.24	TDWDAP0101	"COMMENT:DEV Domino Apps Server (Apps Cluster)	"
10.57.130.25	TDWDEF0101	"COMMENT:DEV Domino eFile Server (Apps Cluster)	"
10.57.130.26	TDWDWB0101	"COMMENT:DEV Domino Web Server"
10.57.130.17	TIWDML0101	"COMMENT:INT Domino Mail Server"
10.57.130.18	TIWDLD0101	"COMMENT:INT Domino LDAP Server"
10.57.130.19	TIWDAP0101	"COMMENT:INT Domino Applications Server (Cluster)"
10.57.130.20	TIWDEF0101	"COMMENT:INT Domino eFile Server (Cluster)"
10.57.130.21	TIWDWB0101	"COMMENT:INT Domino Web Server"

10.30.5.181 tpwfap0101 #COMMENT:"Samba Shared Cluster Node 1"
10.30.5.182 tpwfap0201 #COMMENT:"Samba Shared Cluster Node 2"
10.30.5.183 svrmu2file #COMMENT:"Samba Shared Cluster"
#10.30.5.183 svrmu2file #COMMENT:"Samba Shared Cluster" shares:Data
#10.30.5.183 svrmu2file #COMMENT:"Samba Shared Cluster" shares:DocStore

subpage NETWARE-SERVERS Netware Servers

group-compress Netware Servers
#203.6.218.162   BALFS01 # nwd
#172.18.10.5     BOUFS01 # nwd
#193.200.201.5   LONFS01 # nwd
#172.20.4.110    MELBL01 # nwd
#172.20.4.111    MELBL02 # nwd
#172.20.4.66     MELBL03 # nwd
#172.20.4.19	MELDR1  # nwd
#172.20.4.17     MELDR2  # nwd COMMENT:"ntp2-dns2" 
# 172.29.2.45     MELEN01 # nwd
#172.29.2.46     MELEN02 # nwd
#172.20.4.14     MELFS01 # nwd COMMENT:"ntp1-dns1"
#172.20.4.18     MELPX01 # nwd
# 172.20.4.8	MELZN01 # nwd
#192.168.14.5    NWEDN   # nwd
##192.168.13.5    NWEMU   # nwd
##172.20.4.30	NWTEST1 # nwd
i##203.6.219.130   NWWGL   # nwd
##203.6.218.194   NWWWN   # nwd -decom
# 203.6.218.66    SHPFS01 # nwd -decom
##192.168.17.5	ESSFS01 # nwd

subpage DevTest-SERVERS DevTest

group-compress DevTest Servers
# 192.168.222.235	linidptest1 # COMMENT:"Nam IDP" http://linidptest1.vwa.gov.au:8080/nidp/app/heartbeat;Success  
# 192.168.222.236	linidptest2 # COMMENT:"Nam IDP" http://linidptest2.vwa.gov.au:8080/nidp/app/heartbeat;Success
# 192.168.222.237	linagwtest1 # COMMENT:"Nam AGW" http://linagwtest1.vwa.gov.au/nesp/app/heartbeat;Success	 
# 192.168.222.238	linagwtest2 # COMMENT:"Nam AGW" http://linagwtest2.vwa.gov.au/nesp/app/heartbeat;Success
192.168.222.245	liniciidptest1 # COMMENT:"Nam ICI IDP" http://liniciidptest1.vwa.gov.au:8080/nidp/app/heartbeat;Success
192.168.222.246	liniciidptest2 # COMMENT:"Nam ICI IDP" http://liniciidptest2.vwa.gov.au:8080/nidp/app/heartbeat;Success
192.168.222.247	liniciagwtest1 # COMMENT:"Nam ICI AGW" http://liniciagwtest1.vwa.gov.au/nesp/app/heartbeat;Success
192.168.222.248	liniciagwtest2 # COMMENT:"Nam ICI AGW" http://liniciagwtest2.vwa.gov.au/nesp/app/heartbeat;Success
#172.29.2.179	linvm179 # COMMENT:"Dev-IDVAULT"
172.29.2.245	linvm245 # COMMENT:"Dev-EMPLOYERS"
172.29.3.74	linv3074 # COMMENT:"WorkH Test Exh"
172.29.3.75	linv3075 # COMMENT:"WorkH Test HAN"
# 172.20.4.37     nwvmwc37 #
# 172.20.3.43     winvmds1 # COMMENT:"Domino Int01/Dev01"
#172.29.2.12     winvmdev12 # COMMENT:"Domio Dev Server"
# 172.20.3.57      winvmdev60 # COMMENT:"Domino Dev05"
#172.20.3.81     winvmapl81 # COMMENT:"APL DR"
##172.20.3.27     winvmdc27
#172.29.2.44     winvmdev03 #  notes-port:1352:s:q badnotes-port:2:2:2
#172.20.3.21     winvmdev04 # COMMENT:"Domino Dev04"
# 172.20.3.37	winvmdev06 # COMMENT:"Domino Dev06"
###172.20.3.136    winvmdoordev136 #
#172.20.3.85	winvmint04 #  notes-port:1352:s:q badnotes-port:2:2:2
172.20.3.37	winvmint06 #  notes-port:1352:s:q badnotes-port:
# 172.29.2.180    winvmint180 # 
#172.29.2.184	winvmint184 #
172.20.3.82	winvmsame82 # COMMENT:"Sametime"
172.20.3.134	winvmsmsdev134 # COMMENT:"SMS Integration"
172.20.3.236	winvmsms236 # COMMENT:"SMS Integration"
#172.20.3.61 	winvmwfm61 # COMMENT:"eWFM App Test"
#172.20.3.62 	winvmwfm62 # COMMENT:"eWFM Analyze Test"
#172.20.3.133 	winvmutrm133 # COMMENT:"UAT TRIM Image Lib Server"
#172.20.3.128 	winvmutrmimg128 # COMMENT:"UAT TRIM ISS Server"
10.51.32.39     sdwdor0201 # COMMENT:"Dev Telelogic DOORS Server"

# remove below - Dana - ITSS114141
#172.20.3.86     winvmmq86 #

# 172.29.2.151    winvmrm151 #
# 172.20.3.84     winvmqctest84 # COMMENT:"Q C Test Server"

subpage DOMINO-PORTS Domino Ports

group-compress Domino Ports
##172.29.2.169     apex0015-UAT0014 # notes-port:1352:s:q http://uat0014.services.workcover.vic.gov.au/ badhttp:2:2:2 badnotes-port:2:2:2
#172.29.2.17     apex1016 # notes-port:1352:s:q badnotes-port:2:2:2
#172.20.3.112 	melarc120-ho18 # notes-port:1352:s:q badnotes-port:2:2:2 
172.20.3.112	wpwdom0213-ho18 # COMMENT:"Archive Mail Server HO18" notes-port:1352:s:q badnotes-port:2:2:2
#172.20.3.108    wpwdom0210-ho2clu1  # smtp:s:q notes-port:1352:s:q
172.29.2.37     wpwdom0128-ho13clu2  # smtp:s:q notes-port:1352:s:q  COMMENT:"Domino iNotes Secondary Mail Server"
172.29.2.86     wpwdom0228-ho13  # notes-port:1352:s:q  COMMENT:"Domino iNotes Primary Mail Server"
172.20.3.227	wpwdom0121-HO9clu2 # notes-port:1352:s:q  COMMENT:"Domino Sametime DR Server"
#172.20.3.22	melbms9-ho2clu2  # smtp:s:q notes-port:1352:s:q 
###172.20.3.41     meldap1-HO15   # notes-port:1352:s:q
###172.20.3.48     Meldap2-HO15clu2 # notes-port:1352:s:q # replaced with wpwdom0116
172.20.3.7	melds01-HO1 # notes-port:1352:s:q  http://ho1.vwa.gov.au badhttp:2:2:2
###172.20.3.9      melds3-HO7 # notes-port:1352:s:q  http://HO7.vwa.gov.au/ badhttp:2:2:2 COMMENT:"Internal QPs"
#172.20.3.31     Testds1-Int01 # notes-port:1352:s:q badnotes-port:2:2:2
###172.29.2.86     winino120-ho13 # notes-port:1352:s:q http://ho13.services.workcover.vic.gov.au badhttp:3:3:3 badnotes-port:2:2:2
# winvmarc137 renamed to melarc120
#172.20.3.112    winvmarc137-ho18    # notes-port:1352:s:q
##172.29.2.153	winvmds72-HO16 #  notes-port:1352:s:q badnotes-port:2:2:2 
#172.29.2.33	winvmssn026-APEX0017CLU2 # notes-port:1352:s:q http://APEX0017CLU2.services.workcover.vic.gov.au badhttp:2:2:2 badnotes-port:2:2:2
172.29.2.35     wpwdom0225-apexds19  # notes-port:1352:s:q  http://apexds19.services.workcover.vic.gov.au/ badhttp:2:2:2 badnotes-port:2:2:2
172.29.2.87	wpwdom0125-APEXDS19CLU2 # notes-port:1352:s:q http://APEXDS19CLU2.services.workcover.vic.gov.au badhttp:2:2:2 badnotes-port:2:2:2

subpage CITRIX-SERVERS CITRIX Servers
192.168.222.42	SPWCAG0201	# COMMENT:"Citrix NetScaler"
192.168.222.43	SPWCAG0101	# COMMENT:"Citrix NetScaler"
10.57.132.32	SPWCWI0101	# COMMENT:"Citrix Web Interface Server"
172.20.8.32	SPWCWI0201	# COMMENT:"Citrix Web Interface Server"
172.20.8.30	WPWXAS0201	# COMMENT:"Citrix XenApp Server (Farm)"
172.20.8.31	WPWXAS0101	# COMMENT:"Citrix XenApp Server (Farm)"
172.20.8.33	WPWXAS0202	# COMMENT:"Citrix XenApp Server (Farm)"
172.20.8.34	WPWXAS0102	# COMMENT:"Citrix XenApp Server (Farm)"

subpage UPS-SERVERS UPS Servers
192.168.18.17	WPLVMA0601	# COMMENT:"Bourke St UPS Management"
192.168.20.17	WPLVMA0801	# COMMENT:"Ballarat UPS Management"
192.168.19.18	WPLVMA0901	# COMMENT:"Bendigo UPS Management"
192.168.10.17	WPLVMA1001	# COMMENT:"Mildura UPS Management"
192.168.14.17	WPLVMA1101	# COMMENT:"Dandenong UPS Management"
192.168.13.17	WPLVMA1201	# COMMENT:"Mulgrave UPS Management"
192.168.23.17	WPLVMA1301	# COMMENT:"Traralgon UPS Management"
192.168.25.18	WPLVMA1401	# COMMENT:"Warnnambool UPS Management"
192.168.24.18	WPLVMA1501	# COMMENT:"Wangaratta UPS Management"
192.168.22.18	WPLVMA1601	# COMMENT:"Shepparton UPS Management"
192.168.21.17	WPLVMA0401	# COMMENT:"Yarra St UPS Management"
192.168.17.17	WPLVMA0701	# COMMENT:"Essendon UPS Management"


subpage esx_clients-CLIENTS ESX Clients - View
dispinclude user_hosts/esx-clients

subpage hp_dr HP DR - View
dispinclude user_hosts/hp-dr

subpage extranet_servers Extranet Servers - View
dispinclude user_hosts/extranet-servers

subpage domino_servers Domino Servers - View
dispinclude user_hosts/domino-servers

subpage network_linux_servers Linux Servers - View
dispinclude user_hosts/network_linux_servers

subpage domino_servers_new Domino Servers New - View
dispinclude user_hosts/domino-servers-new

subpage domino_tac_servers_new TAC Domino Servers New - View
dispinclude user_hosts/domino-servers-tac-new

page network Networks

title Networks

subpage AGENT-INTERFACES Agent Interfaces

group-compress AGENT-INTERFACES
192.168.221.2   Allianz-GWIP # COMMENT:"Allianz Agent Interface RT-ALL-SSN-01"
192.168.221.6   Xchanging-GWIP # COMMENT:"Xchanging Agent Interface RT-XCH-SSN-01"
192.168.221.13   WGB-GWIP # COMMENT:"WGB/GBS (GBS is the new name) Agent Interface RT-GBS-SSN-01"
#192.168.221.4   GIO-GWIP # COMMENT:"GIO Agent Interface rogi0001"
192.168.221.9   IAG-GWIP # COMMENT:"IAG/CGU (CGU is the new name) Agent Interface RT-CGU-SSN-01"
192.168.221.3   QBE-GWIP # COMMENT:"QBE Agent Interface RT-QBE-SSN-01"
192.168.221.14  FUJI-Xerox-GWIP # COMMENT:"FUJI-Xerox Firewall Interface RT-FJX-SSN-01"
192.168.221.15  EML-GWIP # COMMENT:"EML Agent interface RT-EML-SSN-01"
# Removed VWA R20995
#172.20.2.9	VWA
#172.29.6.2	VWA-DR

subpage WAN-INTERFACE WAN Interfaces

group-compress WAN-INTERFACES
172.29.8.2	BT-EXH-RADIANZ
172.29.8.3	BT-DR-RADIANZ
172.30.1.2      CSC-Mainframe
172.30.1.3      CSC-Switch
#172.29.7.2 	ROEX0001		
172.29.7.2 	RT-EXH-SSN-01		
172.29.7.7 	PS-EXH-SSN-01		#Blue Coat Packet Shaper
172.30.6.2 	ROCS0001 (CSC)
172.31.1.4	ROCS0002 (CSC DR)
192.168.220.6	ROHICAPS01
192.168.220.7	ROHICAPS02
203.6.217.12    RT-DR-INET
#172.29.2.7      RT-DR-SSAPP # Removed as per requested by David Jeffries on 14/05/2015
#172.29.7.3 	RT-DR-SSN
172.29.7.3 	RT-HAN-SSN-01
203.6.216.29    RT-EXH-CVPN
203.6.217.13	RT-EXH-INET
172.29.8.7	RT-EXH-TACFAX-01  COMMENT:"Rightfax Router"
172.31.1.3	SW-CSC-DR
192.168.30.1   SW-BALLARAT
#203.6.218.161   SW-BALLARAT
192.168.30.2    SW-BENDIGO
#203.6.218.33    SW-BENDIGO
#172.18.10.4	SW-BOURKE-L3
#172.18.10.3	SW-BOURKE-L4
192.168.30.4    SW-DANDENONG
#192.168.14.1    SW-DANDENONG
#192.168.223.13	SW-DR-FW1
#192.168.223.15	SW-DR-FW2
##192.168.223.12	SW-EXH-FW1 # Removed S72100
##192.168.223.14	SW-EXH-FW2 # Removed S72100
##192.168.30.21   SW-EXHIBITION # Removed S72100
192.168.21.1    SW-GEELONG
192.168.30.25   SW-BOURKEST
#192.168.221.14	RT-FJX-SSN-01	#T534440

##192.168.61.5	SW-HAN-FW-01	# COMMENT:"C2960S - Hansens" # Removed S72100
# 172.20.2.9	SW-HAN-CORE-01	# COMMENT:"C3750E - Hansens"
# Removed R20995
#192.168.61.15	SW-HAN-CORE-02	# COMMENT:"C3750E - Hansens"
# Name change R20995
192.168.61.20	SW-HAN-AGG-01	# COMMENT:"NXS-C5010 - Hansens"
192.168.61.21	SW-HAN-AGG-02	# COMMENT:"NXS-C5010 - Hansens"
192.168.61.25	SW-HAN-AGG-03	# COMMENT:"NXS-C5010 - Hansens"
192.168.61.26	SW-HAN-AGG-04	# COMMENT:"NXS-C5010 - Hansens"
192.168.61.30	PL-HAN-MUX-01	# COMMENT:"PL-400E - Hansens"
192.168.61.31	PL-HAN-MUX-02	# COMMENT:"PL-400E - Hansens"
# Added R20995
192.168.61.35	PL-EXH-MUX-01	# COMMENT:"PL-400E - Exh"
192.168.61.36	PL-EXH-MUX-02	# COMMENT:"PL-400E - Exh"

192.168.11.2    SW-LONSDALE
192.168.11.1	SW-LON-L9
192.168.11.3	SW-LON-L11
192.168.11.4	SW-LON-L18
192.168.10.1    SW-MILDURA
192.168.13.1    SW-MULGRAVE
#192.168.223.16	SW-NP-FW1
#192.168.223.17	SW-NP-FW2
192.168.17.1    SW-ESSENDON
192.168.30.10    SW-SHEPPARTON
192.168.30.11   SW-TRARALGON
#203.6.218.129   SW-TRARALGON
192.168.30.12   SW-WANGARATTA
#203.6.218.97    SW-WANGARATTA
192.168.30.13   SW-WARRNAMBOOL
#203.6.218.193   SW-WARRNAMBOOL
192.168.30.30   RS-EXH-EXT-01
192.168.30.31   RS-HAN-EXT-01

subpage LAN-SWITCHES LAN SWITCHES

group-compress LAN-SWITCHES
172.25.255.100  SW-EXH-LGND
172.25.255.107    SW-EXH-L07
172.25.255.109    SW-EXH-L09
172.25.255.110	SW-EXH-L10
172.25.255.117   SW-EXH-L17
172.25.255.118   SW-EXH-L18
172.25.255.119   SW-EXH-L19
172.25.255.120   SW-EXH-L20
172.25.255.121   SW-EXH-L21
172.25.255.122   SW-EXH-L22
172.25.255.123   SW-EXH-L23
172.25.255.124   SW-EXH-L24
172.25.255.125   SW-EXH-L25
172.25.255.126   SW-EXH-L26
172.25.255.127   SW-EXH-L27
172.25.255.128  SW-EXH-L28
172.25.255.7    SW-EXH-L28-1
172.25.255.8    SW-EXH-L28-2
172.20.2.4      RT-EXH-L28_CORE
172.25.255.1    RT-EXH-L28_HSRP
172.25.255.2    RT-EXH-L28-1
172.25.255.3    RT-EXH-L28-2
172.25.255.30   SW-EXH-PABX-1
172.25.255.31   SW-EXH-PABX-2 
192.168.62.20   SW-EXH-L28-3  
192.168.62.21   SW-EXH-L28-4
192.168.62.2	RS-EXH-CORE-01
192.168.62.3	RS-EXH-CORE-02
192.168.62.4	RS-HAN-CORE-01
192.168.62.5 	RS-HAN-CORE-02

subpage Bluecoat-Proxy-Servers Bluecoat-Proxy-Servers 
group-compress Bluecoat-Proxy-Servers
172.20.8.3 WPWBCR0201  # COMMENT:"Bluecoat Proxy Report Server"
172.20.4.201 WPABCP0101  # COMMENT:" Bluecoat Proxy Server - Secondary"
172.20.4.202 WPABCP0201  # COMMENT:" Bluecoat Proxy Server - Primary"
172.20.4.211 WPABCA0101 B  # COMMENT:"Internet AV - Han"
172.20.4.212 WPABCA0201 B  # COMMENT:"Internet AV - 222"


subpage Support-Advisory-Server Support-Advisory-Server
group-compress Support-Advisory-Servers
10.56.138.12	WTWCIC0201 #  COMMENT:"Advisory Server Test"
10.56.138.20	WTWRPT0201 #  COMMENT:"Reporting Advisory Server Test"

subpage TAC-INTERFACES TAC Interfaces

group-compress TAC-INTERFACES
10.30.5.2	SW-HAN-CORE-02
10.30.51.8	TACEXHCORESR02
10.57.123.2	TACGHQSR01
10.57.123.3	TACGHQSR02
10.57.123.13	TACGHQSW01
10.57.123.14	TACGHQSW02
10.57.123.15	TACGHQSW03
10.57.123.16	TACGHQSW04
10.57.123.10	TACGHQSW05
10.57.123.12	TACGHQSW06
10.57.123.11	TACGHQSW07
10.57.123.20	TACGHQFW01
10.57.123.33	TACGHQWLC01
10.57.123.35	TACGHQWLC02
# 10.30.35.34	TACBENSW01
10.30.51.6	TACDRPMBRO01
10.30.51.133	TACEXHCORESW01
10.30.51.7	TACEXHIRO01
10.60.16.33	TACDREXHSE01
10.60.16.6	TACDREXHSW02
10.30.54.6	TACDEVSW02
10.30.54.1	TACDEVDOMAIN_1
10.30.51.10	TACNPGRERO01
10.30.62.225	TACIDSNOBPRO01
10.30.62.102	TAC_DIAL-IP_R01
10.30.58.6	TACNOBPSW03
10.30.62.230	TACNOBPSW05
10.30.5.237	JUNIPER_IDP-200
10.30.63.210	TAC-Mainframe

subpage APPLIANCES APPLIANCES
group-compress APPLIANCES

#### 172.29.2.48     ENLDAP  # 
172.29.2.203    ENLDAP  # 
192.168.222.4   ichain
# 192.168.222.51	icinet01 #   
# 192.168.222.61	icinet02 #  
192.168.223.32	ips-dr # COMMENT:"DR IPS at Hansen" badconn:3:3:3
192.168.223.31	ips-exh # COMMENT:"IPS at Exhibition St" badconn:3:3:3
#192.168.222.135 connect1 # COMMENT:"Aventail EXH"
#192.168.222.136 connect2 # COMMENT:"Aventail HAN"
# 192.168.222.150 linagw1 # COMMENT:"NAM AGW" http://linagw1.vwa.gov.au:8080/nesp/app/heatbeat;Success - OK
# 192.168.222.151 linagw2 # COMMENT:"NAM AGW-DR" http://linagw2.vwa.gov.au:8080/nesp/app/heatbeat;Success - OK
# 192.168.222.155 linidp1 # COMMENT:"NAM IDP" http://linidp1.vwa.gov.au:8080/nidp/app/heartbeat;Success - OK
# 192.168.222.156 linidp2 # COMMENT:"NAM IDP-DR" http://linidp2.vwa.gov.au:8080/nidp/app/heartbeat;Success - OK
192.168.222.228 liniciagw1 # COMMENT:"NAM ICI AGW" http://liniciagw1.vwa.gov.au/nesp/app/heatbeat;Success - OK
192.168.222.229 liniciagw2 # COMMENT:"NAM ICI AGW-DR" http://liniciagw2.vwa.gov.au/nesp/app/heatbeat;Success - OK
192.168.222.226 liniciidp1 # COMMENT:"NAM ICI IDP" http://liniciidp1.vwa.gov.au:8080/nidp/app/heartbeat;Success - OK
192.168.222.227 liniciidp2 # COMMENT:"NAM ICI IDP-DR" http://liniciidp2.vwa.gov.au:8080/nidp/app/heartbeat;Success - OK
# 192.168.222.145	linnamcon1  # COMMENT:"Nam Console"
# 192.168.222.146	linnamcon2  # COMMENT:"Nam Console"
192.168.222.243	linicicon1  # COMMENT:"Nam ICI Console"
192.168.222.244	linicicon2  # COMMENT:"Nam ICI Console"
# 172.20.2.203	melbc01 # COMMENT:"Internet Proxy"
# 172.20.2.204	melbc02 # COMMENT:"CS Internet Proxy"
192.168.223.9   melfm01 # COMMENT:"Checkpoint Firewall"
192.168.223.8	melfm02 # COMMENT:"Checkpoint Firewall"
#192.168.223.20  melfw01
#172.29.2.5	melfw02 #
#172.29.2.161	Novus_Performance #noconn 
203.6.217.7	PShaper_INET
172.20.0.1	PShaper_WAN
#172.20.5.131	RSA1  # COMMENT:"Ops Console" noconn https://rsa1.vwa.gov.au:7072/operations-console/ badhttp:2:2:2
#172.20.5.132	RSA2  # COMMENT:"Ops Console" noconn https://rsa2.vwa.gov.au:7072/operations-console/ badhttp:2:2:2
172.20.3.33     Statseeker1  #
172.25.230.33	WS222WLC1 # COMMENT:"Wireless LAN Controller 1" 
172.25.230.35 	WS222WLC2 # COMMENT:"Wireless LAN Controller 1"

subpage Load Load Balancers
group-compress Load-Balancers
10.30.5.223	spalba0201_1.1_tac-server_vlan5
192.168.222.30	spalba0201_1.2_ichain_vlan9
10.50.0.203	spalba0201_1.2_dmz-prod-appdata_vlan1100
172.29.2.235	spalba0201_1.3_ssnapps_vlan18
172.20.3.233	spalba0201_1.4_internalserver_vlan15
10.51.0.203	spalba0201_1.4_trusted-prod-appdata_vlan2100
172.29.5.203	spalba0201_1.5_ssnapps2_vlan28
172.28.2.203	spalba0201_1.6_nprzone_vlan26
172.28.4.203	spalba0201_1.7_przone_vlan27
10.52.0.203	spalba0201_1.7_restricted-prod-appdata_vlan3100
10.57.130.203	spalba0201_1.8_tac-dev_vlan802
10.50.32.203	spalba0201_1.8_dmz-nonprod-appdata_vlan1200
10.51.32.203	spalba0201_1.8_trusted-nonprod-appdata_vlan2200
10.52.32.203	spalba0201_1.8_restricted-nonprod-appdata_vlan3200

10.30.5.224	spalba0101_1.1_tac-server_vlan5
192.168.222.31	spalba0101_1.2_ichain_vlan9
10.50.0.204	spalba0101_1.2_DMZ-prod-appdata_vlan1100
172.29.2.236	spalba0101_1.3_ssnapps_vlan18
172.20.3.234	spalba0101_1.4_internalserver_vlan15
10.51.0.204	spalba0101_1.4_trusted-prod-appdata_vlan2100
172.29.5.204	spalba0101_1.5_ssnapps2_vlan28
172.28.2.204	spalba0101_1.6_nprzone_vlan26
172.28.4.204	spalba0101_1.7_przone_vlan27
10.52.0.204	spalba0101_1.7_restricted-prod-appdata_vlan3100
10.57.130.204	spalba0101_1.8_tac-dev_vlan802
10.50.32.204	spalba0101_1.8_dmz-nonprod-appdata_vlan1200
10.51.32.204	spalba0101_1.8_trusted-nonprod-appdata_vlan2200
10.52.32.204	spalba0101_1.8_restricted-nonprod-appdata_vlan3200

#172.29.2.201	lb1_ssn 
#172.29.2.202	lb2_ssn 
#192.168.222.201 lb1_ichain_net
#192.168.222.202 lb2_ichain_net
#172.29.2.203	lb_ichain-edir
#172.29.2.204	lb_ichain-was
#192.168.222.50  lb_internet-ichain
10.52.96.82	SPALBA0101
10.52.96.83     SPALBA0201

subpage VPN VPN Appliance
192.168.222.209 STLVPN0201  # COMMENT:"Test VPN appliance"
192.168.222.181 WPUVPN0101  # COMMENT:"Prod VPN appliance"
192.168.222.180 WPUVPN0201  # COMMENT:"Prod VPN appliance"

page MANAPP Managed Applications

subpage AURION Aurion Systems (View)
dispinclude user_hosts/aurion-hosts

subpage ASSYST ASSYST (View)
dispinclude user_hosts/assyst-hosts
172.29.3.177    ldbsdtprod #COMMENT:"Assystnet" assyn-port:8180:s:q
0.0.0.0 assyst # noconn COMMENT:"Assyst Service"

subpage Avanti Avanti Systems (View)
dispinclude user_hosts/avanti-hosts

subpage NEUR Neurogenix (View)
dispinclude user_hosts/neurogenix-hosts

subpage ORR2 ORR2 (View)
dispinclude user_hosts/ors-hosts

subpage WEBCM  VWA WebSite (View)
dispinclude user_hosts/webcm-hosts

#subpage LIC Licensing (View)
#dispinclude user_hosts/licensing-hosts

subpage CASE Case (View)
dispinclude user_hosts/case-hosts

subpage PORT Portal-IM (View)
dispinclude user_hosts/portal-hosts

subpage SAS SAS-EIE (View)
dispinclude user_hosts/sas-hosts

subpage IDM-NAM  IDM-NAM (View)
dispinclude user_hosts/idm_nam-hosts

subpage CAMS CAMS-hosts (View)
dispinclude user_hosts/cams-hosts

subpage WAS WAS-hosts (View)
dispinclude user_hosts/was-hosts

subpage novus NOVUS Prod Servers(View)
dispinclude user_hosts/novus-hosts

#subpage HICAPS-DEV HICAPS DEV (View)
subpage HICAPS HICAPS (View)
dispinclude user_hosts/hicaps-hosts
0.0.0.0 hicaps # noconn COMMENT:"HICAPS Service"

subpage Confluence Confluence (View)
dispinclude user_hosts/confluence-hosts

subpage Source-Control Source-Control (View)
dispinclude user_hosts/source-control-hosts

subpage JIRA JIRA (View)
dispinclude user_hosts/jira-hosts

subpage Hudson Hudson Build (View)
dispinclude user_hosts/hudson-hosts

subpage TPC TPC (View)
dispinclude user_hosts/tpc-hosts

subpage EIP EIP (View)
dispinclude user_hosts/eip-hosts

subpage ELS ELS (View)
dispinclude user_hosts/els-hosts

subpage LNR LNR (View)
dispinclude user_hosts/lnr-hosts

subpage TEMPUS-Prod TEMPUS-Prod (View)
dispinclude user_hosts/tempus-prod-hosts

subpage QAS QAS (View)
dispinclude user_hosts/qas-hosts

subpage POS POS (View)
dispinclude user_hosts/pos-hosts

subpage Data-Mgmt Data-Mgmt (View)
dispinclude user_hosts/data-mgmt

subpage VSphere5-Guests VSphere5-Guests (View)
dispinclude user_hosts/vsphere5-guests

subpage EDRMS-Guests EDRMS-Guests (View)
dispinclude user_hosts/edrms-hosts

subpage WAS-RePlatform WAS-RePlatform (View)
dispinclude user_hosts/warp-hosts

subpage Integration-Platform  Integration-Platform (View)
dispinclude user_hosts/ipup-hosts

subpage TAC-VOICE TAC-VOICE (View)
dispinclude user_hosts/voice-hosts

subpage Quality-Center Quality Center - HP ALM (View)
dispinclude user_hosts/QualityCenter-hosts

subpage CBM-Master CBM Master Servers (View)
dispinclude user_hosts/cbm-master-hosts

subpage Oracle-Financials Oracle Financials (View)
dispinclude user_hosts/oracle-financials

subpage Telelogic-Doors Telelogic Doors (View)
dispinclude user_hosts/telelogic-doors

subpage Assyst-V10 Assyst V10 Servers (View)
dispinclude user_hosts/assyst-v10

subpage P2P-Servers P2P Servers (View)
dispinclude user_hosts/p2p-servers

subpage WSV-VOICE WSV VOICE (View)
dispinclude user_hosts/wsv-voice

subpage WSV-Intranet WSV Intranet (View)
dispinclude user_hosts/wsv-intranet

subpage TAC-Intranet TAC Intranet (View)
dispinclude user_hosts/tac-intranet

subpage Shared-Portal Shared Portal (View)
dispinclude user_hosts/shared-portal

subpage Audio-Visual Audio Visual (View)
dispinclude user_hosts/audio-visual

subpage BigFix-LMT BigFix LMT (View)
dispinclude user_hosts/bigfix-lmt

subpage EPC-Servers EPC Servers (View)
dispinclude user_hosts/epc-servers



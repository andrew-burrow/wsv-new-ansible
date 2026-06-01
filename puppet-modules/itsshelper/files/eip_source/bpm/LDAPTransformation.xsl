<?xml version="1.0" encoding="UTF-8"?>
<!--
Licensed Materials - Property of IBM
5724-L01
(C) Copyright IBM Corporation 2005, 2010. All Rights Reserved.
US Government Users Restricted Rights- Use, duplication or disclosure
restricted by GSA ADP Schedule Contract with IBM Corp.
-->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xalan="http://xml.apache.org/xslt"
               xmlns:staff="http://www.ibm.com/schemas/workflow/wswf/plugins/staff"
               xmlns:sldap="http://www.ibm.com/schemas/workflow/wswf/plugins/staff/ldap"
               version="1.0">
    

    <xsl:output standalone="no"
                encoding="UTF-8"
                omit-xml-declaration="no"
                media-type="text/xml"
                method="xml"
                indent="yes"
                version="1.0"/>

    <xsl:strip-space elements="*"/>
  
    <!-- Begin global variables, adapt if needed -->
    <xsl:variable name="Threshold">1000000</xsl:variable>

    <xsl:variable name="DefaultPersonClass">inetOrgPerson</xsl:variable>
    <xsl:variable name="DefaultUserIdAttribute">uid</xsl:variable>
    <xsl:variable name="DefaultMailAttribute">mail</xsl:variable>
    <xsl:variable name="DefaultLocaleAttribute">preferredLanguage</xsl:variable>
    <xsl:variable name="DefaultManagerAttribute">manager</xsl:variable>
  

    <xsl:variable name="DefaultGroupClass">groupOfNames</xsl:variable>
    <xsl:variable name="DefaultGroupClassMemberAttribute">member</xsl:variable>
    <xsl:variable name="DefaultRecursivity">yes</xsl:variable>


    <xsl:variable name="GS_GroupID">cn</xsl:variable>
    <xsl:variable name="GS_Type">unknown</xsl:variable>
    <xsl:variable name="GS_IndustryType">unknown</xsl:variable>
    <xsl:variable name="GS_BusinessType">businesscategory</xsl:variable>
    <xsl:variable name="GS_GeographicLocation">unknown</xsl:variable>
    <xsl:variable name="GS_Affiliates">unknown</xsl:variable>
    <xsl:variable name="GS_DisplayName">unknown</xsl:variable>
    <xsl:variable name="GS_Secretary">unknown</xsl:variable>
    <xsl:variable name="GS_Assistant">unknown</xsl:variable>
    <xsl:variable name="GS_Manager">unknown</xsl:variable>
    <xsl:variable name="GS_BusinessCategory">unknown</xsl:variable>
    <xsl:variable name="GS_ParentCompany">unknown</xsl:variable>

    <xsl:variable name="PS_UserID">uid</xsl:variable>
    <xsl:variable name="PS_Profile">unknown</xsl:variable>
    <xsl:variable name="PS_LastName">sn</xsl:variable>
    <xsl:variable name="PS_FirstName">unknown</xsl:variable>
    <xsl:variable name="PS_MiddleName">unknown</xsl:variable>
    <xsl:variable name="PS_Email">unknown</xsl:variable>
    <xsl:variable name="PS_Company">unknown</xsl:variable>
    <xsl:variable name="PS_DisplayName">unknown</xsl:variable>
    <xsl:variable name="PS_Assistant">unknown</xsl:variable>
    <xsl:variable name="PS_Secretary">unknown</xsl:variable>
    <xsl:variable name="PS_Manager">manager</xsl:variable>
    <xsl:variable name="PS_Department">unknown</xsl:variable>
    <xsl:variable name="PS_EmployeeID">unknown</xsl:variable>
    <xsl:variable name="PS_TaxPayerID">unknown</xsl:variable>
    <xsl:variable name="PS_Phone">unknown</xsl:variable>
    <xsl:variable name="PS_Fax">unknown</xsl:variable>
    <xsl:variable name="PS_Gender">unknown</xsl:variable>
    <xsl:variable name="PS_Timezone">unknown</xsl:variable>
    <xsl:variable name="PS_PreferredLanguage">unknown</xsl:variable>
    
    <xsl:variable name="DefaultVWAAgentUser">AUVWAMieEmDefaultAgentUser</xsl:variable>
    <xsl:variable name="ACCtionUserID">AUVWAACCtionUserID</xsl:variable>
    <xsl:variable name="PositionID">AUVWATempusDefaultPositionID</xsl:variable>    
    <!-- End global variables -->


    <!-- set retrieval attribute to point to a user id attribute or, for email verbs, to an email attribute -->
    <xsl:variable name="verb" select="normalize-space(/staff:verb/staff:name/text())"/>
    <xsl:variable name="returnAttribute">
        <xsl:choose>
            <xsl:when test="$verb='Email Address for Users by user ID'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
            <xsl:when test="$verb='Email Address for Users'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
            <xsl:when test="$verb='Email Address for Group Members'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
            <xsl:when test="$verb='Email Address for Group Members without Filtered Users'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
            <xsl:when test="$verb='Email Address for Department Members'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
            <xsl:when test="$verb='Email Address for Role Members'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
            <xsl:when test="$verb='Email Address for Group Search'"> <xsl:value-of select="$DefaultMailAttribute"/> </xsl:when>
				
            <xsl:otherwise> <xsl:value-of select="$DefaultUserIdAttribute"/> </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <!-- Begin global dispatching -->
    <xsl:template match="/staff:verb">

        <xsl:variable name="verb1">
            <xsl:value-of select="staff:name/text()"/>
        </xsl:variable>

        <xsl:variable name="verb">
            <xsl:value-of select="normalize-space($verb1)" />
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$verb='Users'">
                <xsl:call-template name="Users"/>
            </xsl:when>
            <xsl:when test="$verb='Users by user ID'">
                <xsl:call-template name="UsersByUserID"/>
            </xsl:when>
            <xsl:when test="$verb='Users by user ID without Named Users'">
                <xsl:call-template name="UsersByUserIDWithoutNamedUsers"/>
            </xsl:when>
            <xsl:when test="$verb='User Records by user ID'">
                <xsl:call-template name="UserRecordsByUserID"/>
            </xsl:when>
            <xsl:when test="$verb='User Records by user ID without Named Users'">
                <xsl:call-template name="UserRecordsByUserIDWithoutNamedUsers"/>
            </xsl:when>
            <xsl:when test="$verb='Group Members'">
                <xsl:call-template name="GroupMembers"/>
            </xsl:when>
            <xsl:when test="$verb='Group Members without Named Users'">
                <xsl:call-template name="GroupMembersWithoutNamedUsers"/>
            </xsl:when>
            <xsl:when test="$verb='Group Members without Filtered Users'">
                <xsl:call-template name="GroupMembersWithoutFilteredUsers"/>
            </xsl:when>
            <xsl:when test="$verb='Role Members'">
                <xsl:call-template name="RoleMembers"/>
            </xsl:when>
            <xsl:when test="$verb='Department Members'">
                <xsl:call-template name="DepartmentMembers"/>
            </xsl:when>
            <xsl:when test="$verb='Manager of Employee'">
                <xsl:call-template name="ManagerOfEmployee"/>
            </xsl:when>
            <xsl:when test="$verb='Manager of Employee by user ID'">
                <xsl:call-template name="ManagerOfEmployeeByUserID"/>
            </xsl:when>
            <xsl:when test="$verb='Person Search'">
                <xsl:call-template name="PersonSearch"/>
            </xsl:when>
            <xsl:when test="$verb='Group Search'">
                <xsl:call-template name="GroupSearch"/>
            </xsl:when>
            <xsl:when test="$verb='Native Query'">
                <xsl:call-template name="NativeQuery"/>
            </xsl:when>
            <xsl:when test="$verb='Everybody'">
                <xsl:call-template name="Everybody"/>
            </xsl:when>
            <xsl:when test="$verb='Nobody'">
                <xsl:call-template name="Nobody"/>
            </xsl:when>
            <xsl:when test="$verb='Group'">
                <xsl:call-template name="Group"/>
            </xsl:when>
            <xsl:when test="$verb='Groups'">
                <xsl:call-template name="Groups"/>
            </xsl:when>
            <xsl:when test="$verb='Users by user ID and groups'">
                <xsl:call-template name="UsersByUserIDAndGroups"/>
            </xsl:when>
            <xsl:when test="$verb='Intersection of Group Members'">
                <xsl:call-template name="IntersectionOfGroupMembers"/>
            </xsl:when>

            <!-- email verbs -->
            <!-- special implementation for this case -->
            <xsl:when test="$verb='Email Address for Users by user ID'">
                <xsl:call-template name="EmailForUsersByUserID"/>
            </xsl:when>
      
            <!-- these email verbs map onto regular verbs, as 'returnAttribute' is set to point to an email attribute -->
            <xsl:when test="$verb='Email Address for Users'">
                <xsl:call-template name="Users"/>
            </xsl:when>
            <xsl:when test="$verb='Email Address for Group Members'">
                <xsl:call-template name="GroupMembers"/>
            </xsl:when>
            <xsl:when test="$verb='Email Address for Group Members without Filtered Users'">
                <xsl:call-template name="GroupMembersWithoutFilteredUsers"/>
            </xsl:when>
            <xsl:when test="$verb='Email Address for Department Members'">
                <xsl:call-template name="DepartmentMembers"/>
            </xsl:when>
            <xsl:when test="$verb='Email Address for Role Members'">
                <xsl:call-template name="RoleMembers"/>
            </xsl:when>
            <xsl:when test="$verb='Email Address for Group Search'">
                <xsl:call-template name="GroupSearch"/>
            </xsl:when>
                
            <xsl:otherwise>
                <xsl:message terminate="no">ERROR: Unsupported verb: '<xsl:value-of select="$verb"/>'.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- End global dispatching -->

    <!-- Begin helper templates for default result objects specifying user data to retrieve -->
    <xsl:template name="ResultObjectSpecForUserData">
        <sldap:resultObject>
            <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
            <xsl:attribute name="usage">simple</xsl:attribute>
		
            <sldap:resultAttribute>
                <xsl:attribute name="name"><xsl:value-of select="$returnAttribute"/></xsl:attribute>
                <xsl:attribute name="destination">userID</xsl:attribute>
            </sldap:resultAttribute>		
            <sldap:resultAttribute>
                <xsl:attribute name="name"><xsl:value-of select="$DefaultMailAttribute"/></xsl:attribute>
                <xsl:attribute name="destination">eMailAddress</xsl:attribute>
            </sldap:resultAttribute>			
            <sldap:resultAttribute>
                <xsl:attribute name="name"><xsl:value-of select="$DefaultLocaleAttribute"/></xsl:attribute>
                <xsl:attribute name="destination">preferredLocale</xsl:attribute>
            </sldap:resultAttribute>
        </sldap:resultObject>
    </xsl:template>

    <xsl:template name="ResultObjectSpecForGroupUserData">
        <sldap:resultObject>
            <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultGroupClass"/></xsl:attribute>	
            <xsl:attribute name="usage">recursive</xsl:attribute>
  	
            <sldap:resultAttribute>
                <xsl:attribute name="name"><xsl:value-of select="$DefaultGroupClassMemberAttribute"/></xsl:attribute>	
                <xsl:attribute name="destination">intermediate</xsl:attribute>
            </sldap:resultAttribute>
        </sldap:resultObject>

        <xsl:call-template name="ResultObjectSpecForUserData" />
    </xsl:template>
    <!-- End helper template for specifying default result entity for user data -->



    <!-- Begin template Users and children -->
    <xsl:template name="Users">
        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='Name']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeName1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeName2']"/>
        </xsl:variable>
        <xsl:variable name="Name3">
            <xsl:value-of select="staff:parameter[@id='AlternativeName3']"/>
        </xsl:variable>
        <xsl:variable name="Name4">
            <xsl:value-of select="staff:parameter[@id='AlternativeName4']"/>
        </xsl:variable>
        <xsl:variable name="Name5">
            <xsl:value-of select="staff:parameter[@id='AlternativeName5']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetUser">
                <xsl:with-param name="username">
                    <xsl:value-of select="$Name0"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetUser">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetUser">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name2"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name3!=''">
                <xsl:call-template name="GetUser">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name3"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name4!=''">
                <xsl:call-template name="GetUser">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name4"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name5!=''">
                <xsl:call-template name="GetUser">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name5"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>

    <xsl:template name="GetUser">
        <xsl:param name="username">default</xsl:param>
        <sldap:user>
            <xsl:attribute name="dn">
                <xsl:value-of select="$username"/>
            </xsl:attribute>
      

            <xsl:call-template name="ResultObjectSpecForUserData" />
      

        </sldap:user>
    </xsl:template>
    <!-- End template Users and children -->



    <!-- Begin template UsersByUserID and children -->
    <xsl:template name="UsersByUserID">
        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='UserID']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeID1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeID2']"/>
        </xsl:variable>
        <xsl:variable name="Name3">
            <xsl:value-of select="staff:parameter[@id='AlternativeID3']"/>
        </xsl:variable>
        <xsl:variable name="Name4">
            <xsl:value-of select="staff:parameter[@id='AlternativeID4']"/>
        </xsl:variable>
        <xsl:variable name="Name5">
            <xsl:value-of select="staff:parameter[@id='AlternativeID5']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetUserByID">
                <xsl:with-param name="username">
                    <xsl:value-of select="$Name0"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name2"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name3!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name3"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name4!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name4"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name5!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name5"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>

    <xsl:template name="GetUserByID">
        <xsl:param name="username">default</xsl:param>
        <sldap:userID>
            <xsl:attribute name="name">
                <xsl:value-of select="$username"/>
            </xsl:attribute>
        </sldap:userID>
    </xsl:template>
    <!-- End template UsersByUserID and children -->



    <!-- Begin template UsersByUserIDWithtoutNamedUsers -->
    <xsl:template name="UsersByUserIDWithoutNamedUsers">
        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='UserID']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeID1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeID2']"/>
        </xsl:variable>
        <xsl:variable name="Name3">
            <xsl:value-of select="staff:parameter[@id='AlternativeID3']"/>
        </xsl:variable>
        <xsl:variable name="Name4">
            <xsl:value-of select="staff:parameter[@id='AlternativeID4']"/>
        </xsl:variable>
        <xsl:variable name="Name5">
            <xsl:value-of select="staff:parameter[@id='AlternativeID5']"/>
        </xsl:variable>
        <sldap:staffQueries>
            <xsl:call-template name="GetUserByID">
                <xsl:with-param name="username">
                    <xsl:value-of select="$Name0"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name2"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name3!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name3"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name4!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name4"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name5!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name5"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>

            <sldap:remove>
                <xsl:attribute name="value"><xsl:value-of select="staff:parameter[@id='NamedUsers']"/></xsl:attribute>
            </sldap:remove>

        </sldap:staffQueries>
    </xsl:template>
    <!-- End template UsersByUserIDWithoutNamedUsers -->


    <!-- Begin template UserRecordsByUserID and children -->
    <xsl:template name="UserRecordsByUserID">
        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='UserID']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeID1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeID2']"/>
        </xsl:variable>
        <xsl:variable name="Name3">
            <xsl:value-of select="staff:parameter[@id='AlternativeID3']"/>
        </xsl:variable>
        <xsl:variable name="Name4">
            <xsl:value-of select="staff:parameter[@id='AlternativeID4']"/>
        </xsl:variable>
        <xsl:variable name="Name5">
            <xsl:value-of select="staff:parameter[@id='AlternativeID5']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetUserRecordByID">
                <xsl:with-param name="username">
                    <xsl:value-of select="$Name0"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name2"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name3!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name3"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name4!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name4"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name5!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name5"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>

    <xsl:template name="GetUserRecordByID">
        <xsl:param name="username">default</xsl:param>
    

        <sldap:search>
            <xsl:attribute name="filter">
                <xsl:value-of select="$DefaultUserIdAttribute"/>=<xsl:value-of select="$username"/>
            </xsl:attribute>
            <xsl:attribute name="searchScope">subtreeScope</xsl:attribute>
            <xsl:attribute name="recursive">no</xsl:attribute>
            <xsl:call-template name="ResultObjectSpecForUserData" />
        </sldap:search>
    </xsl:template>
    <!-- End template UserRecordsByUserID and children -->


    <!-- Begin template UserRecordsByUserIDWithoutNamedUsers and children -->
    <xsl:template name="UserRecordsByUserIDWithoutNamedUsers">
        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='UserID']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeID1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeID2']"/>
        </xsl:variable>
        <xsl:variable name="Name3">
            <xsl:value-of select="staff:parameter[@id='AlternativeID3']"/>
        </xsl:variable>
        <xsl:variable name="Name4">
            <xsl:value-of select="staff:parameter[@id='AlternativeID4']"/>
        </xsl:variable>
        <xsl:variable name="Name5">
            <xsl:value-of select="staff:parameter[@id='AlternativeID5']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetUserRecordByID">
                <xsl:with-param name="username">
                    <xsl:value-of select="$Name0"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name2"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name3!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name3"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name4!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name4"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name5!=''">
                <xsl:call-template name="GetUserRecordByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name5"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>

            <sldap:remove>
                <xsl:attribute name="value"><xsl:value-of select="staff:parameter[@id='NamedUsers']"/></xsl:attribute>
            </sldap:remove>
      

        </sldap:staffQueries>
    </xsl:template>
    <!-- End template UserRecordsByUserIDWithoutNamedUsers and children -->


    <!-- Begin template GroupMembers and children -->
    <xsl:template name="GroupMembers">
        <xsl:variable name="Group0">
            <xsl:value-of select="staff:parameter[@id='GroupName']"/>
        </xsl:variable>
        <xsl:variable name="Group1">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupName1']"/>
        </xsl:variable>
        <xsl:variable name="Group2">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupName2']"/>
        </xsl:variable>
        <xsl:variable name="Group3">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupName3']"/>
        </xsl:variable>
        <xsl:variable name="Group4">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupName4']"/>
        </xsl:variable>
        <xsl:variable name="Group5">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupName5']"/>
        </xsl:variable>
        <xsl:variable name="includesubgroups">
            <xsl:value-of select="staff:parameter[@id='IncludeSubgroups']"/>
        </xsl:variable>
      

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetGroupMembers">
                <xsl:with-param name="setname">  <xsl:value-of select="$Group0"/> </xsl:with-param>
                <xsl:with-param name="includesubsets"> <xsl:value-of select="$includesubgroups"/> </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Group1!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Group1"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includesubgroups"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Group2!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Group2"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includesubgroups"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Group3!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Group3"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includesubgroups"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Group4!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Group4"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includesubgroups"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Group5!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Group5"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includesubgroups"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>

    <xsl:template name="GetGroupMembers">
        <xsl:param name="setname">default</xsl:param>
        <xsl:param name="includesubsets">yes</xsl:param>
        <sldap:usersOfGroup>
            <xsl:attribute name="groupDN">
                <xsl:value-of select="$setname"/>
            </xsl:attribute>
      

            <xsl:choose>
                <xsl:when test="$includesubsets='false'">
                    <xsl:attribute name="recursive">no</xsl:attribute>
                </xsl:when>
                <xsl:when test="$includesubsets='true'">
                    <xsl:attribute name="recursive">yes</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                     <xsl:message terminate="no">WARNING: Unexpected value: '<xsl:value-of select="$includesubsets"/>' for including subsets. Continue using the default value 'true'.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="ResultObjectSpecForGroupUserData" />

        </sldap:usersOfGroup>
    </xsl:template>
    <!-- End template GroupMembers and children -->


    <!-- Begin template GroupMembersWithoutNamedUsers -->
    <xsl:template name="GroupMembersWithoutNamedUsers">
    

        <sldap:staffQueries>
            <sldap:usersOfGroup>
                <xsl:attribute name="groupDN">
                    <xsl:value-of select="staff:parameter[@id='GroupName']"/>
                </xsl:attribute>
            

                <xsl:choose>
                    <xsl:when test="staff:parameter[@id='IncludeSubgroups']='false'">
                        <xsl:attribute name="recursive">no</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="staff:parameter[@id='IncludeSubgroups']='true'">
                        <xsl:attribute name="recursive">yes</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="no">WARNING: Unexpected value: '<xsl:value-of select="staff:parameter[@id='IncludeSubgroups']"/>' for IncludeSubgroups. Continue using the default value 'true'.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:call-template name="ResultObjectSpecForGroupUserData" />

            </sldap:usersOfGroup>

            <sldap:remove>
                <xsl:attribute name="value"><xsl:value-of select="staff:parameter[@id='NamedUsers']"/></xsl:attribute>
            </sldap:remove>
        </sldap:staffQueries>

    </xsl:template>
    <!-- End template GroupMembersWithoutNamedUsers -->
    


    <!-- Begin template GroupMembersWithoutFilteredUsers -->
    <xsl:template name="GroupMembersWithoutFilteredUsers">
    

        <sldap:staffQueries>
            <sldap:usersOfGroup>
                <xsl:attribute name="groupDN">
                    <xsl:value-of select="staff:parameter[@id='GroupName']"/>
                </xsl:attribute>

                <xsl:choose>
                    <xsl:when test="staff:parameter[@id='IncludeSubgroups']='false'">
                        <xsl:attribute name="recursive">no</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="staff:parameter[@id='IncludeSubgroups']='true'">
                        <xsl:attribute name="recursive">yes</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="no">WARNING: Unexpected value: '<xsl:value-of select="staff:parameter[@id='IncludeSubgroups']"/>' for IncludeSubgroups. Continue using the default value 'true'.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
    

                <xsl:call-template name="ResultObjectSpecForGroupUserData" />
            </sldap:usersOfGroup>

            <sldap:intermediateResult>
                <xsl:attribute name="name">filteredusers</xsl:attribute>
                <sldap:search>
                    <xsl:attribute name="filter">
                        <xsl:value-of select="staff:parameter[@id='FilterAttribute']"/>=<xsl:value-of select="staff:parameter[@id='FilterValue']"/>
                    </xsl:attribute>
                    <xsl:attribute name="searchScope">subtreeScope</xsl:attribute>
                    <xsl:attribute name="recursive">no</xsl:attribute>

                    <xsl:call-template name="ResultObjectSpecForUserData" />
                </sldap:search>
            </sldap:intermediateResult>

            <sldap:remove>
                <xsl:attribute name="value">%filteredusers%</xsl:attribute>
            </sldap:remove>

        </sldap:staffQueries>

    </xsl:template>
    <!-- End template GroupMembersWithoutFilteredUsers -->


    <!-- Begin template RoleMembers -->
    <xsl:template name="RoleMembers">
        <xsl:variable name="Role0">
            <xsl:value-of select="staff:parameter[@id='RoleName']"/>
        </xsl:variable>
        <xsl:variable name="Role1">
            <xsl:value-of select="staff:parameter[@id='AlternativeRoleName1']"/>
        </xsl:variable>
        <xsl:variable name="Role2">
            <xsl:value-of select="staff:parameter[@id='AlternativeRoleName2']"/>
        </xsl:variable>
        <xsl:variable name="Role3">
            <xsl:value-of select="staff:parameter[@id='AlternativeRoleName3']"/>
        </xsl:variable>
        <xsl:variable name="Role4">
            <xsl:value-of select="staff:parameter[@id='AlternativeRoleName4']"/>
        </xsl:variable>
        <xsl:variable name="Role5">
            <xsl:value-of select="staff:parameter[@id='AlternativeRoleName5']"/>
        </xsl:variable>
        <xsl:variable name="includeNestedRoles">
            <xsl:value-of select="staff:parameter[@id='IncludeNestedRoles']"/>
        </xsl:variable>
        <sldap:staffQueries>
            <xsl:attribute name="threshold"><xsl:value-of select="$Threshold"/></xsl:attribute>
            <xsl:call-template name="GetGroupMembers">
                <xsl:with-param name="setname"> <xsl:value-of select="$Role0"/> </xsl:with-param>
                <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedRoles"/> </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Role1!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Role1"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedRoles"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Role2!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Role2"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedRoles"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Role3!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Role3"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedRoles"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Role4!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Role4"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedRoles"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Role5!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Role5"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedRoles"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template RoleMembers -->



    <!-- Begin template DepartmentMembers -->
    <xsl:template name="DepartmentMembers">
        <xsl:variable name="Dept0">
            <xsl:value-of select="staff:parameter[@id='DepartmentName']"/>
        </xsl:variable>
        <xsl:variable name="Dept1">
            <xsl:value-of select="staff:parameter[@id='AlternativeDepartmentName1']"/>
        </xsl:variable>
        <xsl:variable name="Dept2">
            <xsl:value-of select="staff:parameter[@id='AlternativeDepartmentName2']"/>
        </xsl:variable>
        <xsl:variable name="Dept3">
            <xsl:value-of select="staff:parameter[@id='AlternativeDepartmentName3']"/>
        </xsl:variable>
        <xsl:variable name="Dept4">
            <xsl:value-of select="staff:parameter[@id='AlternativeDepartmentName4']"/>
        </xsl:variable>
        <xsl:variable name="Dept5">
            <xsl:value-of select="staff:parameter[@id='AlternativeDepartmentName5']"/>
        </xsl:variable>
        <xsl:variable name="includeNestedDepartments">
            <xsl:value-of select="staff:parameter[@id='IncludeNestedDepartments']"/>
        </xsl:variable>
        <sldap:staffQueries>
            <xsl:attribute name="threshold"><xsl:value-of select="$Threshold"/></xsl:attribute>
            <xsl:call-template name="GetGroupMembers">
                <xsl:with-param name="setname"> <xsl:value-of select="$Dept0"/> </xsl:with-param>
                <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedDepartments"/> </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Dept1!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Dept1"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedDepartments"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Dept2!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Dept2"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedDepartments"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Dept3!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Dept3"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedDepartments"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Dept4!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Dept4"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedDepartments"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Dept5!=''">
                <xsl:call-template name="GetGroupMembers">
                    <xsl:with-param name="setname"> <xsl:value-of select="$Dept5"/> </xsl:with-param>
                    <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeNestedDepartments"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template DepartmentMembers -->


    <!-- Begin template ManagerOfEmployee -->
    <xsl:template name="ManagerOfEmployee">
        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>

            <sldap:intermediateResult>
                <xsl:attribute name="name">manager</xsl:attribute>
                <sldap:user>
                    <xsl:attribute name="dn">
                        <xsl:value-of select="staff:parameter[@id='EmployeeName']"/>
                    </xsl:attribute>
          
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>

                        <sldap:resultAttribute>
                            <xsl:attribute name="name"><xsl:value-of select="$DefaultManagerAttribute"/></xsl:attribute>
                            <xsl:attribute name="destination">intermediate</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>

                </sldap:user>
            </sldap:intermediateResult>

            <sldap:user>
                <xsl:attribute name="dn">%manager%</xsl:attribute>
                <xsl:call-template name="ResultObjectSpecForUserData" />
            </sldap:user>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template ManagerOfEmployee -->



    <!-- Begin template ManagerOfEmployeeByUserID-->
    <xsl:template name="ManagerOfEmployeeByUserID">
        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>

            <sldap:intermediateResult>
                <xsl:attribute name="name">manager</xsl:attribute>
                <sldap:search>
                    <xsl:attribute name="filter">
                        <xsl:value-of select="$DefaultUserIdAttribute"/>=<xsl:value-of select="staff:parameter[@id='EmployeeUserID']"/>
                    </xsl:attribute>
                    <xsl:attribute name="searchScope">subtreeScope</xsl:attribute>
                    <xsl:attribute name="recursive">no</xsl:attribute>
          
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>

                        <sldap:resultAttribute>
                            <xsl:attribute name="name"><xsl:value-of select="$DefaultManagerAttribute"/></xsl:attribute>
                            <xsl:attribute name="destination">intermediate</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>
                </sldap:search>
            </sldap:intermediateResult>

            <sldap:user>
                <xsl:attribute name="dn">%manager%</xsl:attribute>
                <xsl:call-template name="ResultObjectSpecForUserData" />
            </sldap:user>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template ManagerOfEmployeeByUserID-->


    <!-- Begin template PersonSearch -->
    <xsl:template name="PersonSearch">

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>

            <sldap:search>
                <xsl:variable name="filtercontent">
                    <xsl:if test="staff:parameter[@id='UserID']!=''">(<xsl:value-of select="$PS_UserID"/>=<xsl:value-of select="staff:parameter[@id='UserID']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Profile']!=''">(<xsl:value-of select="$PS_Profile"/>=<xsl:value-of select="staff:parameter[@id='Profile']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='LastName']!=''">(<xsl:value-of select="$PS_LastName"/>=<xsl:value-of select="staff:parameter[@id='LastName']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='FirstName']!=''">(<xsl:value-of select="$PS_FirstName"/>=<xsl:value-of select="staff:parameter[@id='FirstName']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='MiddleName']!=''">(<xsl:value-of select="$PS_MiddleName"/>=<xsl:value-of select="staff:parameter[@id='MiddleName']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Email']!=''">(<xsl:value-of select="$PS_Email"/>=<xsl:value-of select="staff:parameter[@id='Email']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Company']!=''">(<xsl:value-of select="$PS_Company"/>=<xsl:value-of select="staff:parameter[@id='Company']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='DisplayName']!=''">(<xsl:value-of select="$PS_DisplayName"/>=<xsl:value-of select="staff:parameter[@id='DisplayName']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Assistant']!=''">(<xsl:value-of select="$PS_Assistant"/>=<xsl:value-of select="staff:parameter[@id='Assistant']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Secretary']!=''">(<xsl:value-of select="$PS_Secretary"/>=<xsl:value-of select="staff:parameter[@id='Secretary']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Manager']!=''">(<xsl:value-of select="$PS_Manager"/>=<xsl:value-of select="staff:parameter[@id='Manager']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Department']!=''">(<xsl:value-of select="$PS_Department"/>=<xsl:value-of select="staff:parameter[@id='Department']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='EmployeeID']!=''">(<xsl:value-of select="$PS_EmployeeID"/>=<xsl:value-of select="staff:parameter[@id='EmployeeID']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='TaxPayerID']!=''">(<xsl:value-of select="$PS_TaxPayerID"/>=<xsl:value-of select="staff:parameter[@id='TaxPayerID']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Phone']!=''">(<xsl:value-of select="$PS_Phone"/>=<xsl:value-of select="staff:parameter[@id='Phone']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Fax']!=''">(<xsl:value-of select="$PS_Fax"/>=<xsl:value-of select="staff:parameter[@id='Fax']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Gender']!=''">(<xsl:value-of select="$PS_Gender"/>=<xsl:value-of select="staff:parameter[@id='Gender']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Timezone']!=''">(<xsl:value-of select="$PS_Timezone"/>=<xsl:value-of select="staff:parameter[@id='Timezone']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='PreferredLanguage']!=''">(<xsl:value-of select="$PS_PreferredLanguage"/>=<xsl:value-of select="staff:parameter[@id='PreferredLanguage']"/>)</xsl:if>
                </xsl:variable>      
                <xsl:attribute name="filter">(&amp; <xsl:value-of select="normalize-space($filtercontent)"/>)</xsl:attribute>

                <xsl:attribute name="searchScope">subtreeScope</xsl:attribute>
                <xsl:attribute name="recursive">
                    <xsl:value-of select="$DefaultRecursivity"/>
                </xsl:attribute>
        
                <xsl:call-template name="ResultObjectSpecForUserData" />
            </sldap:search>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template PersonSearch -->



    <!-- Begin template GroupSearch -->
    <xsl:template name="GroupSearch">

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>

            <sldap:search>
                <xsl:variable name="filtercontent">
                    <xsl:if test="staff:parameter[@id='GroupID']!=''">(<xsl:value-of select="$GS_GroupID"/>=<xsl:value-of select="staff:parameter[@id='GroupID']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Type']!=''">(<xsl:value-of select="$GS_Type"/>=<xsl:value-of select="staff:parameter[@id='Type']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='IndustryType']!=''">(<xsl:value-of select="$GS_IndustryType"/>=<xsl:value-of select="staff:parameter[@id='IndustryType']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='BusinessType']!=''">(<xsl:value-of select="$GS_BusinessType"/>=<xsl:value-of select="staff:parameter[@id='BusinessType']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='GeographicLocation']!=''">(<xsl:value-of select="$GS_GeographicLocation"/>=<xsl:value-of select="staff:parameter[@id='GeographicLocation']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Affiliates']!=''">(<xsl:value-of select="$GS_Affiliates"/>=<xsl:value-of select="staff:parameter[@id='Affiliates']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='DisplayName']!=''">(<xsl:value-of select="$GS_DisplayName"/>=<xsl:value-of select="staff:parameter[@id='DisplayName']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Secretary']!=''">(<xsl:value-of select="$GS_Secretary"/>=<xsl:value-of select="staff:parameter[@id='Secretary']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Assistant']!=''">(<xsl:value-of select="$GS_Assistant"/>=<xsl:value-of select="staff:parameter[@id='Assistant']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='Manager']!=''">(<xsl:value-of select="$GS_Manager"/>=<xsl:value-of select="staff:parameter[@id='Manager']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='BusinessCategory']!=''">(<xsl:value-of select="$GS_BusinessCategory"/>=<xsl:value-of select="staff:parameter[@id='BusinessCategory']"/>)</xsl:if>
                    <xsl:if test="staff:parameter[@id='ParentCompany']!=''">(<xsl:value-of select="$GS_ParentCompany"/>=<xsl:value-of select="staff:parameter[@id='ParentCompany']"/>)</xsl:if>
                </xsl:variable>      
                <xsl:attribute name="filter">(&amp; <xsl:value-of select="normalize-space($filtercontent)"/>)</xsl:attribute>
        
                <xsl:attribute name="searchScope">subtreeScope</xsl:attribute>
                <xsl:attribute name="recursive">
                    <xsl:value-of select="$DefaultRecursivity"/>
                </xsl:attribute>

                <xsl:call-template name="ResultObjectSpecForGroupUserData" />
            </sldap:search>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template GroupSearch -->



    <!-- Begin template NativeQuery -->
    <xsl:template name="NativeQuery">
        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>

            <!-- Allow multiple Native Query templates-->
            <xsl:choose>
                <!-- Template 'uidSearch' . It originally is template 'search' -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='uidSearch'">
                    <sldap:search>
                        <xsl:attribute name="filter">
                            <xsl:value-of select="staff:parameter[@id='Query']"/>
                        </xsl:attribute>
                        <xsl:attribute name="recursive">
                            <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                        </xsl:attribute>
                        <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                            <xsl:attribute name="baseDN">
                                <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                            </xsl:attribute>
                        </xsl:if>

                        <xsl:call-template name="ResultObjectSpecForGroupUserData" />
                    </sldap:search>
                </xsl:when>
        
                <!-- Template 'agentSearch' -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='agentSearch'">

                <sldap:intermediateResult>	 
                    <xsl:attribute name="name">agent</xsl:attribute>	
                    <sldap:search>
                       <xsl:attribute name="filter">
                          <xsl:value-of select="staff:parameter[@id='Query']"/>
                       </xsl:attribute>
                       <xsl:attribute name="recursive">
                          <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                       </xsl:attribute>
                       <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                          <xsl:attribute name="baseDN">
                            <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                          </xsl:attribute>
                       </xsl:if>
                      
                        <sldap:resultObject>
                            <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultGroupClass"/></xsl:attribute>
                            <xsl:attribute name="usage">simple</xsl:attribute>
                            
                            <sldap:resultAttribute>
                                <xsl:attribute name="name"><xsl:value-of select="$DefaultVWAAgentUser"/></xsl:attribute>
                                <xsl:attribute name="destination">intermediate</xsl:attribute>
                            </sldap:resultAttribute>
                        </sldap:resultObject>	
                    </sldap:search>
                </sldap:intermediateResult>
            
              <sldap:user>
                <xsl:attribute name="dn">%agent%</xsl:attribute>        
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name">cn</xsl:attribute>
                            <xsl:attribute name="destination">userID</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>
              </sldap:user>

                
                </xsl:when>
                
                <!-- Template 'searchACCtionUser'. This is a custom WorkSafe template to obtain the acction userid from the user name -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='searchACCtionUserID'">
                  <sldap:search>
                    <xsl:attribute name="filter">
                      <xsl:value-of select="staff:parameter[@id='Query']"/>
                    </xsl:attribute>
                    <xsl:attribute name="recursive">
                      <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                    </xsl:attribute>
                    <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                      <xsl:attribute name="baseDN">
                        <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                      </xsl:attribute>
                    </xsl:if>			
                    
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name"><xsl:value-of select="$ACCtionUserID"/></xsl:attribute>
                            <xsl:attribute name="destination">userID</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>	
                    
                  </sldap:search>
                </xsl:when>
                
                <!-- Template 'searchDefaultPosition'. This is a custom WorkSafe template to obtain the default position ID for an agent -->
                <!--  Written by Graham Rivers-Brown -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='searchDefaultPosition'">
                  <sldap:search>
                    <xsl:attribute name="filter">
                      <xsl:value-of select="staff:parameter[@id='Query']"/>
                    </xsl:attribute>
                    <xsl:attribute name="recursive">
                      <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                    </xsl:attribute>
                    <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                      <xsl:attribute name="baseDN">
                        <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                      </xsl:attribute>
                    </xsl:if>			
                    
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultGroupClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name"><xsl:value-of select="$PositionID"/></xsl:attribute>
                            <xsl:attribute name="destination">userID</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>	
                    
                  </sldap:search>
                </xsl:when>
                
                <!-- Template 'searchGroupByAgent'. This is a custom WorkSafe template to obtain the group for an agent -->
                <!--  Written by JC Lee -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='searchGroupByAgent'">
                  <sldap:search>
                    <xsl:attribute name="filter">
                      <xsl:value-of select="staff:parameter[@id='Query']"/>
                    </xsl:attribute>
                    <xsl:attribute name="recursive">
                      <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                    </xsl:attribute>
                    <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                      <xsl:attribute name="baseDN">
                        <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                      </xsl:attribute>
                    </xsl:if>			
                    
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultGroupClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name">cn</xsl:attribute>
                            <xsl:attribute name="destination">userID</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>	
                    
                  </sldap:search>
                </xsl:when>				
                
                <!-- Template 'searchGroupMembership'. This template overrides the resultObject of the previous template 'search' -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='searchGroupMembership'">
                  <sldap:search>
                    <xsl:attribute name="filter">
                      <xsl:value-of select="staff:parameter[@id='Query']"/>
                    </xsl:attribute>
                    <xsl:attribute name="recursive">
                      <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                    </xsl:attribute>
                    <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                      <xsl:attribute name="baseDN">
                        <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                      </xsl:attribute>
                    </xsl:if>			
                    
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name">groupMembership</xsl:attribute>
                            <xsl:attribute name="destination">userID</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>				
                  </sldap:search>
                </xsl:when>

                <!-- Template 'search'. This template overrides the resultObject of the previous template 'search' -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='search'">
                  <sldap:search>
                    <xsl:attribute name="filter">
                      <xsl:value-of select="staff:parameter[@id='Query']"/>
                    </xsl:attribute>
                    <xsl:attribute name="recursive">
                      <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                    </xsl:attribute>
                    <xsl:if test="staff:parameter[@id='AdditionalParameter2']!=''">
                      <xsl:attribute name="baseDN">
                        <xsl:value-of select="staff:parameter[@id='AdditionalParameter2']"/>
                      </xsl:attribute>
                    </xsl:if>			
                    
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name">cn</xsl:attribute>
                            <xsl:attribute name="destination">userID</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>	
                    
                  </sldap:search>
                </xsl:when>

                <!-- Template 'user' -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='user'">
                    <sldap:user>
                        <xsl:attribute name="dn">
                            <xsl:value-of select="staff:parameter[@id='Query']"/>
                        </xsl:attribute>
                        <xsl:call-template name="ResultObjectSpecForUserData" />
                    </sldap:user>
                </xsl:when>
        
                <!-- Template 'usersOfGroup' -->
                <xsl:when test="staff:parameter[@id='QueryTemplate']='usersOfGroup'">
                    <sldap:usersOfGroup>
                        <xsl:attribute name="groupDN">
                            <xsl:value-of select="staff:parameter[@id='Query']"/>
                        </xsl:attribute>
                        <xsl:attribute name="recursive">
                            <xsl:value-of select="staff:parameter[@id='AdditionalParameter1']"/>
                        </xsl:attribute>
            

                        <xsl:call-template name="ResultObjectSpecForGroupUserData" />

                    </sldap:usersOfGroup>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">ERROR: Native query template '<xsl:value-of select="staff:parameter[@id='QueryTemplate']"/>' is not supported by the LDAP XSL transformation. Supported values are: 'search', 'user' and 'usersOfGroup'.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template NativeQuery -->



    <!-- Begin template Everybody -->
    <xsl:template name="Everybody">
        <sldap:staffQueries>
            <sldap:everybody/>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template Everybody -->



    <!-- Begin template Nobody -->
    <xsl:template name="Nobody">
        <sldap:staffQueries>
            <sldap:nobody/>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template Nobody -->


    <!-- Begin template Group -->
    <xsl:template name="Group">
        <xsl:variable name="GroupID">
            <xsl:value-of select="staff:parameter[@id='GroupID']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:call-template name="GetGroup">
                <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID"/> </xsl:with-param>
            </xsl:call-template>
        </sldap:staffQueries>
    </xsl:template>

    <xsl:template name="GetGroup">
        <xsl:param name="groupname">default</xsl:param>
        <sldap:groupID>
            <xsl:attribute name="name">
                <xsl:value-of select="$groupname"/>
            </xsl:attribute>
        </sldap:groupID>
    </xsl:template>
    <!-- End template Group -->



    <!-- Begin template Groups -->
    <xsl:template name="Groups">
        <xsl:variable name="GroupID0">
            <xsl:value-of select="staff:parameter[@id='GroupID']"/>
        </xsl:variable>
        <xsl:variable name="GroupID1">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID1']"/>
        </xsl:variable>
        <xsl:variable name="GroupID2">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID2']"/>
        </xsl:variable>
        <xsl:variable name="GroupID3">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID3']"/>
        </xsl:variable>
        <xsl:variable name="GroupID4">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID4']"/>
        </xsl:variable>
        <xsl:variable name="GroupID5">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID5']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:call-template name="GetGroup">
                <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID0"/> </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$GroupID1!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID1"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID2!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID2"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID3!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID3"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID4!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID4"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID5!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID5"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template Groups -->



    <!-- Begin template UsersByUserIDAndGroups -->
    <xsl:template name="UsersByUserIDAndGroups">
        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='UserID']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeUserID1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeUserID2']"/>
        </xsl:variable>
        <xsl:variable name="Name3">
            <xsl:value-of select="staff:parameter[@id='AlternativeUserID3']"/>
        </xsl:variable>
        <xsl:variable name="Name4">
            <xsl:value-of select="staff:parameter[@id='AlternativeUserID4']"/>
        </xsl:variable>
        <xsl:variable name="Name5">
            <xsl:value-of select="staff:parameter[@id='AlternativeUserID5']"/>
        </xsl:variable>
        <xsl:variable name="GroupID0">
            <xsl:value-of select="staff:parameter[@id='GroupID']"/>
        </xsl:variable>
        <xsl:variable name="GroupID1">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID1']"/>
        </xsl:variable>
        <xsl:variable name="GroupID2">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID2']"/>
        </xsl:variable>
        <xsl:variable name="GroupID3">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID3']"/>
        </xsl:variable>
        <xsl:variable name="GroupID4">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID4']"/>
        </xsl:variable>
        <xsl:variable name="GroupID5">
            <xsl:value-of select="staff:parameter[@id='AlternativeGroupID5']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetUserByID">
                <xsl:with-param name="username"> <xsl:value-of select="$Name0"/> </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username"> <xsl:value-of select="$Name1"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username"> <xsl:value-of select="$Name2"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name3!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username"> <xsl:value-of select="$Name3"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name4!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username"> <xsl:value-of select="$Name4"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name5!=''">
                <xsl:call-template name="GetUserByID">
                    <xsl:with-param name="username"> <xsl:value-of select="$Name5"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="GetGroup">
                <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID0"/> </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$GroupID1!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID1"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID2!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID2"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID3!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID3"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID4!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID4"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$GroupID5!=''">
                <xsl:call-template name="GetGroup">
                    <xsl:with-param name="groupname"> <xsl:value-of select="$GroupID5"/> </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template UsersByUserIDAndGroups -->


    <!-- Begin template IntersectionOfGroupMembers -->
    <xsl:template name="IntersectionOfGroupMembers">
        <xsl:variable name="Group0">
            <xsl:value-of select="staff:parameter[@id='GroupName']"/>
        </xsl:variable>
        <xsl:variable name="Group1">
            <xsl:value-of select="staff:parameter[@id='OtherGroupName']"/>
        </xsl:variable>
        <xsl:variable name="includeSubgroups">
            <xsl:value-of select="staff:parameter[@id='IncludeSubgroups']"/>
        </xsl:variable>        
        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetGroupMembers">
                <xsl:with-param name="setname">  <xsl:value-of select="$Group0"/> </xsl:with-param>
                <xsl:with-param name="includesubsets"> <xsl:value-of select="$includeSubgroups"/> </xsl:with-param>
            </xsl:call-template>
            <sldap:intermediateResult>
                <xsl:attribute name="name">otherGroupMembers</xsl:attribute>
                <sldap:usersOfGroup>
                    <xsl:attribute name="groupDN">
                        <xsl:value-of select="$Group1"/>
                    </xsl:attribute>

                    <xsl:choose>
                        <xsl:when test="$includeSubgroups='false'">
                            <xsl:attribute name="recursive">no</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$includeSubgroups='true'">
                            <xsl:attribute name="recursive">yes</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                             <xsl:message terminate="no">WARNING: Unexpected value: '<xsl:value-of select="$includeSubgroups"/>' for including subsets. Continue using the default value 'true'.</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>

                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultGroupClass"/></xsl:attribute>	
                        <xsl:attribute name="usage">recursive</xsl:attribute>

                        <sldap:resultAttribute>
                            <xsl:attribute name="name"><xsl:value-of select="$DefaultGroupClassMemberAttribute"/></xsl:attribute>	
                            <xsl:attribute name="destination">intermediate</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>
                    
                    <sldap:resultObject>
                        <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                        <xsl:attribute name="usage">simple</xsl:attribute>
                        <sldap:resultAttribute>
                            <xsl:attribute name="name"><xsl:value-of select="$DefaultUserIdAttribute"/></xsl:attribute>
                            <xsl:attribute name="destination">intermediate</xsl:attribute>
                        </sldap:resultAttribute>
                    </sldap:resultObject>

                </sldap:usersOfGroup>

            </sldap:intermediateResult>
            <sldap:intersect>
                <xsl:attribute name="value">%otherGroupMembers%</xsl:attribute>
            </sldap:intersect>
        </sldap:staffQueries>
    </xsl:template>
    <!-- End template IntersectionOfGroupMembers -->

    <!-- email verb templates -->

    <!-- Begin template EmailForUsersByUserID -->
    <xsl:template name="EmailForUsersByUserID">

        <xsl:variable name="Name0">
            <xsl:value-of select="staff:parameter[@id='UserID']"/>
        </xsl:variable>
        <xsl:variable name="Name1">
            <xsl:value-of select="staff:parameter[@id='AlternativeID1']"/>
        </xsl:variable>
        <xsl:variable name="Name2">
            <xsl:value-of select="staff:parameter[@id='AlternativeID2']"/>
        </xsl:variable>

        <sldap:staffQueries>
            <xsl:attribute name="threshold">
                <xsl:value-of select="$Threshold"/>
            </xsl:attribute>
            <xsl:call-template name="GetEmailForUserByID">
                <xsl:with-param name="username">
                    <xsl:value-of select="$Name0"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$Name1!=''">
                <xsl:call-template name="GetEmailForUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name1"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$Name2!=''">
                <xsl:call-template name="GetEmailForUserByID">
                    <xsl:with-param name="username">
                        <xsl:value-of select="$Name2"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </sldap:staffQueries>
    </xsl:template>

    <xsl:template name="GetEmailForUserByID">
        <xsl:param name="username">default</xsl:param>

        <sldap:search>
            <xsl:attribute name="filter">
                <xsl:value-of select="$DefaultUserIdAttribute"/>=<xsl:value-of select="$username"/>
            </xsl:attribute>
            <xsl:attribute name="searchScope">subtreeScope</xsl:attribute>
            <xsl:attribute name="recursive">
                <xsl:value-of select="$DefaultRecursivity"/>
            </xsl:attribute>

            <sldap:resultObject>
                <xsl:attribute name="objectclass"><xsl:value-of select="$DefaultPersonClass"/></xsl:attribute>
                <xsl:attribute name="usage">simple</xsl:attribute>
                
                <sldap:resultAttribute>
                    <xsl:attribute name="name"><xsl:value-of select="$DefaultMailAttribute"/></xsl:attribute>
                    <xsl:attribute name="destination">userID</xsl:attribute>
                </sldap:resultAttribute>
            </sldap:resultObject>
        </sldap:search>
    
    </xsl:template>
    <!-- End template EmailForUsersByUserID -->

</xsl:transform>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.jivesoftware.xmpp.workgroup.Workgroup,
                 org.jivesoftware.xmpp.workgroup.WorkgroupManager,
                 org.jivesoftware.xmpp.workgroup.spi.ChatHistoryUtils,
                 org.jivesoftware.xmpp.workgroup.utils.ModelUtil,
                 org.jivesoftware.util.Log,
                 org.jivesoftware.util.ParamUtils,
                 org.xmpp.packet.JID,
                 java.text.DateFormat,
                 java.text.DecimalFormat,
                 java.text.SimpleDateFormat,
                 java.util.Date"
    %>
<%
    WorkgroupManager wgManager = WorkgroupManager.getInstance();

    boolean submit = request.getParameter("submit") != null;

    boolean errors = false;
    String errorMessage = "";

    String start = request.getParameter("startDate");
    String end = request.getParameter("endDate");

    Date startDate = null;
    Date endDate = null;

    if (submit) {

        if (start == null || "".equals(start)) {
            errors = true;
            start = "";
            errorMessage = "Please specify a valid start date.";
        }
        else {
            DateFormat formatter;
            if (start.contains("/")) {
                // This was used by the old calendarjs code. Retain it to not break old links/bookmarks, etc.
                formatter = new SimpleDateFormat("MM/dd/yy");
            } else {
                formatter = new SimpleDateFormat("yyyy-MM-dd");
            }
            try {
                startDate = formatter.parse(start);
            }
            catch (Exception e) {
                errors = true;
                start = "";
                errorMessage = "Please specify a valid start date.";
                Log.error(e);
            }
        }

        if (end == null || "".equals(end)) {
            errors = true;
            end = "";
            errorMessage = "Please specify a valid end date.";
        }
        else {
            DateFormat formatter;
            if (end.contains("/")) {
                // This was used by the old calendarjs code. Retain it to not break old links/bookmarks, etc.
                formatter = new SimpleDateFormat("MM/dd/yy");
            } else {
                formatter = new SimpleDateFormat("yyyy-MM-dd");
            }
            try {
                endDate = formatter.parse(end);
            }
            catch (Exception e) {
                errors = true;
                end = "";
                errorMessage = "Please specify a valid end date.";
                Log.error(e);
            }
        }
    }

%>

<html>
<head>
    <title>Usage Summary</title>
    <meta name="pageID" content="usage-summary"/>
    <!--<meta name="helpPage" content="view_workgroup_usage_reports.html"/>-->

    <style type="text/css">
        .textfield {
            font-size: 11px;
            font-family: verdana;
            padding: 3px 2px;
            background: #efefef;
        }

        .text {
            font-size: 11px;
            font-family: verdana;
        }
    </style>
</head>

<body>
<style type="text/css">
    @import "style/style.css";
</style>
<% if(errors){ %>
<div class="error">
    <%= errorMessage%>
</div>
<% } %>

<p>
    <span class="jive-description">This reports shows historical information on overall usage for all Workgroups.
    </span>
</p>

<div  class="jive-contentBox">
      <h4>Overall Usage Summary</h4>
    <table class="box" cellpadding="3" cellspacing="1" border="0">


        <tr>
            <td width="1%" class="text" nowrap>
                Total number of users entering chat queues:
            </td>
            <td class="text">
                <%= ChatHistoryUtils.getTotalRequestCountForSystem() %>
            </td>
        </tr>
        <tr>
            <td width="1%" class="text" nowrap>
                Number of users served by agents:
            </td>
            <td class="text">
                <%= ChatHistoryUtils.getTotalChatsInSystem() %>
            </td>
        </tr>
        <tr>
            <td width="1%" class="text" nowrap>
                Percentage of users served by an agent:
            </td>
            <td class="text">
                <%
                    int totalRequests = ChatHistoryUtils.getTotalRequestCountForSystem();
                    int totalChats = ChatHistoryUtils.getTotalChatsInSystem();
                    DecimalFormat format = new DecimalFormat(".00");
                    double per = (double)totalChats / totalRequests * 100;
                    if (totalChats == 0 || totalRequests == 0) {
                        out.println("Not Available");
                    }
                    else {
                        String percentage = format.format((double)totalChats / totalRequests * 100);
                        out.println(percentage + "%");
                    }
                %>
            </td>
        </tr>
        <tr>
            <td width="1%" class="text" nowrap>
                Average user wait time prior to being served:
            </td>
            <td class="text">
                <%= ChatHistoryUtils.getAverageWaitTimeForServer() %>
            </td>
        </tr>
        <tr>
            <td width="1%" class="text" nowrap>
                Average length of a user chat session:
            </td>
            <td class="text">
                <%= ChatHistoryUtils.getDateFromLong(ChatHistoryUtils.getAverageChatLengthForServer()) %>
            </td>
        </tr>
        <tr>
            <td width="1%" class="text" nowrap>
                Total length of all user chat sessions:
            </td>
            <td class="text">
                <%= ChatHistoryUtils.getDateFromLong(ChatHistoryUtils.getTotalTimeForAllChatsInServer()) %>
            </td>
        </tr>

    </table>
</div>
<br/>

<form name="workgroupForm" method="post" action="usage-summary.jsp">
<div  class="jive-contentBox">
      <h4>Workgroup Summaries</h4>
<table class="box" cellpadding="3" cellspacing="1" border="0">
<tr>
    <td width="1%" nowrap class="text">
        Select Workgroup:
    </td>
    <td class="text" width="99%" nowrap>
        <select name="workgroupBox">
            <%
                String wgroup = request.getParameter("workgroupBox");
                for (Workgroup w : wgManager.getWorkgroups()) {
                    String selectionID = "";
                    if (wgroup != null && wgroup.equals(w.getJID().toString())) {
                        selectionID = "selected";
                    }
            %>
            <option value="<%= w.getJID().toString() %>" <%= selectionID %>>
                <%= w.getJID().toString() %>
            </option>
            <%
                }
            %>
        </select>


    </td>
</tr>
<tr>
<td width="1%" nowrap class="text">
    Choose Date
</td>
    <td width="99%" class="text" nowrap>
        <label for="startDate">From:</label>&nbsp;<input type="date" name="startDate" id="startDate" size="15" value="<%= start != null ? start : ""%>"/>
        <label for="endDate">To:</label>&nbsp;<input type="date" name="endDate" id="endDate" size="15" value="<%= end != null ? end : "" %>"/>
    </td>
</tr>
</table>
<table class="box"  width="500">
<tr>
    <td width="1%" colspan="2">
    <input type="submit" name="submit" value="View Statistics"/>
</td>
</tr>
<%
    String workgroupName = ParamUtils.getParameter(request, "workgroupBox");
%>



<% if (ModelUtil.hasLength(workgroupName) && !errors) { %>


<%
    if (workgroupName != null) {
        final Workgroup g = wgManager.getWorkgroup(new JID(workgroupName));
        String name = g.getJID().toString();
%>
<tr>
     <td width="1%" class="text" nowrap colspan="2">Usage Summary for <b><%= name %></b> between <%= start%> and <%= end%><br/><br/></td>
</tr>
<tr>

      <td width="1%" class="text" nowrap> Total number of users entering chat queues:</td>
     <td width="1%" class="text" nowrap>
        <%= ChatHistoryUtils.getNumberOfRequestsForWorkgroup(name, startDate, endDate) %>
    </td>
</tr>
<tr>
      <td width="1%" class="text" nowrap>Number of chat users served by agents:</td>
     <td width="1%" class="text" nowrap>
        <%= ChatHistoryUtils.getNumberOfChatsAccepted(name, startDate, endDate) %>
    </td>
</tr>
<tr>
      <td width="1%" class="text" nowrap>Number of users cancelling request</td>
      <td width="1%" class="text" nowrap>
        <%= ChatHistoryUtils.getNumberOfRequestsCancelledByUser(name, startDate, endDate) %>
    </td>
</tr><tr>
      <td width="1%" class="text" nowrap>Number of users never picked up by an agent:</td>
      <td width="1%" class="text" nowrap>
        <%= ChatHistoryUtils.getNumberOfRequestsNeverPickedUp(name, startDate, endDate) %>
    </td>
</tr>

<tr>
     <td width="1%" class="text" nowrap>Average user wait time prior to being served</td>
     <td width="1%" class="text" nowrap>
        <%= ChatHistoryUtils.getDateFromLong(ChatHistoryUtils.getAverageWaitTimeForWorkgroup(name, startDate, endDate)) %>
    </td>
</tr><tr>
     <td width="1%" class="text" nowrap>
        Total length of all customer chat sessions:</td>
     <td width="1%" class="text" nowrap>
        <%= ChatHistoryUtils.getDateFromLong(ChatHistoryUtils.getTotalChatTimeForWorkgroup(name))%>
    </td>
</tr>
<% } %>
<% } %>
</table>
</div>
</form>

<script type="text/javascript">
    function catcalc(cal) {
        var endDateField = $('endDate');
        var startDateField = $('startDate');

        var endTime = new Date(endDateField.value);
        var startTime = new Date(startDateField.value);
        if (endTime.getTime() < startTime.getTime()) {
            alert("Dates do not match");
            startDateField.value = "";
            endDateField.value= "";
        }
    }
</script>
</body>
</html>


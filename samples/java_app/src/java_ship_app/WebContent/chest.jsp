<%@ page language="java" import="java.util.*" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Chest</title>
</head>
<body>
<p>
Chest scanner (attribute - value):
<br> -- begin --
<% 
@SuppressWarnings("unchecked")
Enumeration<String> e = (Enumeration<String>)session.getAttributeNames();
while( e.hasMoreElements() ) {     
    String attribName = (String) e.nextElement();
    Object attribValue = session.getAttribute(attribName);
%>
<br><%= attribName %> - <%= attribValue %>
<%
}
%>
<br> -- end --
</p>
<p><a href="chestservlet">Put sth in the chest.</a></p>
<br>
<a href=index.jsp>Click here to go back</a>
</body>
</html>
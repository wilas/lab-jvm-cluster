<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Greeting Form</title>
</head>
<body>
	<%
		java.text.DateFormat df = new java.text.SimpleDateFormat(
				"dd/MM/yyyy");
	%>
	<p>
		Today is:
		<%=df.format(new java.util.Date())%>
	</p>
	<form action="greetingservlet" method="POST">
		First Name: <input type="text" name="firstName" size="20"><br>
		Surname: <input type="text" name="surname" size="20"> <br>
		<br> <input type="submit" value="Submit">
	</form>
	<br>
	<a href=index.jsp>Click here to go back</a>
</body>
</html>
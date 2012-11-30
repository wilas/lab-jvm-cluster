package me.ship;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Enumeration;

//import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

/**
 * Servlet implementation class WineMenu
 */
public class WineMenu extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public WineMenu() {
		super();
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		InitialContext initialContext;
		PrintWriter out = response.getWriter();
		try {
			initialContext = new InitialContext();
			DataSource ds = (DataSource) initialContext
					.lookup("java:/comp/env/jdbc/wine_cellar");
			// This works too
			// Context context = (Context)
			// initialContext.lookup("java:comp/env");
			// DataSource ds = (DataSource) context.lookup("jdbc/wine_cellar");

			Connection connection = ds.getConnection();
			String query = "SELECT name FROM wine";
			PreparedStatement statement = connection.prepareStatement(query);
			ResultSet rs = statement.executeQuery();
			out.println("<!DOCTYPE html>");
			out.println("<html>");
			out.println("<head>");
			out.println("<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>");
			out.println("<title>DB example</title>");
			out.println("</head>");
			out.println("<body>");
			out.println("<a href=index.jsp>Click here to go back </a>");
			out.println("<h1>Wine Menu from wine_cellar DB:</h1>");
			while (rs.next()) {
				out.print(rs.getString("name") + "</br>");
			}
			out.println("</br>");

			out.println("<h1>Server Details:</h1>");
			ServletContext servletcontext = this.getServletContext();
			out.println("request.getServerName(): " + request.getServerName());
			out.println("</br>");
			out.println("request.getContextPath(): " + request.getContextPath());
			out.println("</br>");
			out.print("servletcontext.getServerInfo(): "
					+ servletcontext.getServerInfo());
			out.println("</br>");
			String clientBrowser = "Not known!";
			String userAgent = request.getHeader("user-agent");
			if (userAgent != null)
				clientBrowser = userAgent;
			out.println("client.browser: " + clientBrowser);
			out.println("</br>");
			out.println("</br>");
			out.println("AppServer NetworkInterface INFO: </br>");
			Enumeration<NetworkInterface> e = NetworkInterface
					.getNetworkInterfaces();
			while (e.hasMoreElements()) {
				NetworkInterface ni = e.nextElement();
				Enumeration<InetAddress> e2 = ni.getInetAddresses();
				while (e2.hasMoreElements()) {
					InetAddress ip = e2.nextElement();
					out.println(ip + "</br>");
				}
			}
			out.println("</body>");
			out.println("</html>");

			rs.close();
			statement.close();
			connection.close();

		} catch (NamingException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			out.close();
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}

}

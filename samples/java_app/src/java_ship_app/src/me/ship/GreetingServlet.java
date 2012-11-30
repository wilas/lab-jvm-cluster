package me.ship;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class GreetingServlet
 */
public class GreetingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GreetingServlet() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		RequestDispatcher view = request.getRequestDispatcher("/greeting.jsp");
		view.forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        String firstName = request.getParameter("firstName").toString();
        String surname = request.getParameter("surname").toString();

        out.println("<html>");
        out.println("<head>");
        out.println("<title>GreetingServlet</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<p>GreetingServlet<p>");
        out.println("<p>Welcome: <b>"+ firstName + " " + surname + "</b> at <i>" + request.getContextPath() + "</i></p>");
        out.println("<br>");
        out.println("<a href=index.jsp> Click here to go back </a>");
        out.println("</body>");
        out.println("</html>");

        out.close();
	}

}

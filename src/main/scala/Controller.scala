import java.io.{FileInputStream, FileNotFoundException, IOException, InputStreamReader}
import scala.util.Try

object Controller {
  def main(args: Array[String]): Unit =
    // Since I'm using JFlex, let's do it a bit "Java style"
    Try(new FileInputStream(args(0)))
      .map(new InputStreamReader(_, "UTF-8"))
      .map(new Lexer(_))
      .map(new Syntax(_))
      .fold({
        case _: FileNotFoundException =>
          System.err.println(s"Missing path: ${args.head}")
        case e: Exception =>
          System.err.println(s"Unexpected exception: ${e.getMessage}")
      }, { syntax =>
        syntax.parse()
        Try(args(1)).toOption match {
          case Some("both") =>
            println("AST graph:")
            syntax.compiler.printRootAST()
            println("ASM listing:")
            syntax.compiler.printRootASM()
          case Some("ast") => syntax.compiler.printRootAST()
          case Some("asm") => syntax.compiler.printRootASM()
          case None        => println("No option specified. Either 'ast' or 'asm'")
        }
      })
}

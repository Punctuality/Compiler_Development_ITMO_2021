import java.util.concurrent.atomic.AtomicInteger

class Compiler {

  private var rootTree: Option[Tree] = None
  def setRoot(root: Tree): Unit = rootTree = Some(root)

  private val tmpCount = new AtomicInteger(0)
  private val lblCount = new AtomicInteger(0)

  private def getNextTmp: String = s"__tmp${tmpCount.getAndIncrement()}"
  private def getNextLbl(spec: String): String = s"__label_${spec}_${lblCount.getAndIncrement()}"

  def printRootAST(): Unit = rootTree match {
    case Some(root) => printTree(root, 0, "")
    case None       => System.err.println("COMPILER -> Found no root!!!")
  }

  def printRootASM(): Unit = rootTree match {
    case Some(root) => printAssembler(root)
    case None       => System.err.println("COMPILER -> Found no root!!!")
  }

  private def printTree(tree: Tree, offset: Int, prefix: String): Unit = {
    println(s"$prefix $offset| ${tree.name} <- [${tree.treeType.toString}]")
    if(tree.children.nonEmpty) {
      tree.children.foreach( child =>
        printTree(child, offset + 1, prefix.concat("\t"))
      )
    }
  }

  private def printAssembler(tree: Tree): Unit = {
    if (tree.children.length > 1) {
      val operators = tree.children(1)
      if (operators.children.nonEmpty)
        printAsmOperators(operators.children.head)
      else
        System.err.println("COMPILER -> Operators are empty")
    } else
      System.err.println("COMPILER -> Empty program")

  }

  private def printAsmOperators(tree: Tree): Unit = tree.name match {
    case "Operators" => tree.children.foreach(printAsmOperators)
    case "Operator"  => printAsmOperator(tree.children.head)
    case "While"     => printAsmWhile(tree)
    case undfOp      => System.err.println(s"COMPILER -> Found undefined operator: $undfOp")
  }

  private def printAsmOperator(operator: Tree): Unit = operator.children(1).treeType match {
    case TreeType.Const | TreeType.Identifier =>
      operator.name match {
        case ":=" => println(s"mov ${operator.children.head.name} ${operator.children(1).name}")
        case name => println(s"${operator.children.head.name} $name ${operator.children(1).name}")
      }
    case TreeType.Expression =>
      val tmpName = printAsmExpression(operator.children(1))
      operator.name match {
        case ":=" => println(s"mov ${operator.children.head.name} $tmpName")
        case name => println(s"${operator.children.head.name} $name $tmpName")
      }

    case otherType =>
      System.err.println(s"COMPILER -> Unsupported operator type: $otherType")
  }

  private def printAsmWhile(whileT: Tree): Unit = {
    val startLabel = getNextLbl("start")
    val stopLabel = getNextLbl("end")

    println(s"$startLabel:")
    val expTmpName = printAsmExpression(whileT.children.head)
    println(s"jz $expTmpName $stopLabel")
    printAsmOperators(whileT.children(1))
    println(s"jmp $startLabel")
    println(s"$stopLabel:")
  }

  private def printAsmExpression(expr: Tree): String = {
    val tmpName = getNextTmp

    val fstValue = expr.children.head.treeType match {
      case TreeType.Const | TreeType.Identifier => expr.children.head.name
      case TreeType.Expression => printAsmExpression(expr.children.head)
      case otherType =>
        System.err.println(s"COMPILER -> Unsupported operator type: $otherType"); ""
    }

    expr.children(1).treeType match {
      case TreeType.UnaryOp =>
        println(s"mov $tmpName (${expr.children(1).name.head} $fstValue)");
      case TreeType.BinaryOp =>
        val sndValue = expr.children(2).treeType match {
          case TreeType.Const | TreeType.Identifier => expr.children(2).name
          case TreeType.Expression => printAsmExpression(expr.children(2));
          case otherType =>
            System.err.println(s"COMPILER -> Unsupported operator type: $otherType"); ""
        }
        println(s"mov $tmpName ($fstValue ${expr.children(1).name} $sndValue)")
      case otherType =>
        System.err.println(s"COMPILER -> Unsupported operator type: $otherType")
    }

    tmpName
  }
}

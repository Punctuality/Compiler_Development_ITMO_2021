import scala.collection.mutable

class AST(compiler: Compiler) {
  private val globalVariables = new mutable.HashSet[String]()

  def jcAddAstNode(parent: String, children: Array[Tree]): Tree =
    addAstNode(parent, children.toList:_*)
  def jcAddAstNode(parent: String, child: Tree): Tree =
    addAstNode(parent, child)
  def addAstNode(parent: String, children: Tree*): Tree = {
    val parentNode = Tree(parent) withChildren (children:_*)

    if (parent == "Root") {
      compiler.setRoot(parentNode)
    }

    parentNode
  }

  def identifierRef(idName: String): Tree =
    if (globalVariables.contains(idName)) {
      Tree(idName) withType TreeType.Identifier
    } else {
      System.err.println(s"COMPILER -> Identifier $idName wasn't declared")
      System.exit(1)
      null
    }

  def constantRef(value: String): Tree =
    Tree(value) withType TreeType.Const

  def jcAddVariable(idName: String, otherVariables: Tree): Tree =
    addVariable(idName, Option(otherVariables))
  def addVariable(idName: String, otherVariables: Option[Tree]): Tree = {
    globalVariables.add(idName)
    val varNode = Tree("Variables list") withType TreeType.Enumeration
    varNode.withChildren(List(Some(identifierRef(idName)), otherVariables).flatten)
  }

  def addAssigment(idName: String, expression: Tree): Tree = {
    val assigment = Tree(":=") withChildren (identifierRef(idName) :: expression :: Nil)
    Tree("Operator") withType TreeType.Operator withChildren assigment
  }
}

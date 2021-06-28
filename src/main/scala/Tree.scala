case class Tree(name: String, treeType: TreeType, children: List[Tree]) {
  def withChildren(children: Tree*): Tree = withChildren(children.toList)
  def withChildren(children: List[Tree]): Tree = this.copy(children = children)

  def withType(newType: TreeType): Tree = this.copy(treeType = newType)
}

object Tree {
  def apply(name: String): Tree = name match {
    case "--" =>
      Tree(name, TreeType.UnaryOp, List.empty)
    case "+" | "-" | "*" | "/" | ">" | "<" | "==" =>
      Tree(name, TreeType.BinaryOp, List.empty)
    case ":=" => Tree(name, TreeType.Assigment, List.empty)
    case "Var" | "While" => Tree(name, TreeType.Keyword, List.empty)
    case "Expression" => Tree(name, TreeType.Expression, List.empty)
    case "Operators" => Tree(name, TreeType.Enumeration, List.empty)
    case "Root" |
         "Variables Declaration" |
         "Program Description" => Tree(name, TreeType.ProgramStructural, List.empty)
    case _ => Tree(name, TreeType.Custom(""), List.empty)
  }
}
sealed trait TreeType

object TreeType {
  case object BinaryOp extends TreeType
  case object UnaryOp extends TreeType
  case object Assigment extends TreeType
  case object Keyword extends TreeType
  case object Expression extends TreeType
  case object Identifier extends TreeType
  case object Operator extends TreeType
  case object Const extends TreeType
  case object ProgramStructural extends TreeType
  case object Enumeration extends TreeType
  case class Custom(customType: String) extends TreeType
}
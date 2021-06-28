import scala.sys.process._

name := "compiler"

version := "0.1"

scalaVersion := "2.13.6"

lazy val execScript = taskKey[Unit]("Execute the compiling for Flex/Bison")

execScript := {
  "compile_flex_bison.sh" !
}
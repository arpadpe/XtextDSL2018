/*
 * generated by Xtext 2.12.0
 */
package dk.sdu.generator

import dk.sdu.wPage.Action
import dk.sdu.wPage.AdvancedType
import dk.sdu.wPage.Alert
import dk.sdu.wPage.Boolean
import dk.sdu.wPage.Button
import dk.sdu.wPage.Click
import dk.sdu.wPage.Css
import dk.sdu.wPage.CssClass
import dk.sdu.wPage.CssConfiguration
import dk.sdu.wPage.CssId
import dk.sdu.wPage.Dimension
import dk.sdu.wPage.DisplayConfiguration
import dk.sdu.wPage.GroupedView
import dk.sdu.wPage.Header
import dk.sdu.wPage.Height
import dk.sdu.wPage.Image
import dk.sdu.wPage.Include
import dk.sdu.wPage.Number
import dk.sdu.wPage.Page
import dk.sdu.wPage.Row
import dk.sdu.wPage.Script
import dk.sdu.wPage.Style
import dk.sdu.wPage.Table
import dk.sdu.wPage.Text
import dk.sdu.wPage.Title
import dk.sdu.wPage.Type
import dk.sdu.wPage.Variable
import dk.sdu.wPage.View
import dk.sdu.wPage.ViewConfiguration
import dk.sdu.wPage.Width
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.wPage.Editable
import dk.sdu.wPage.TextValue
import dk.sdu.wPage.IfElse
import dk.sdu.wPage.Disjunction
import dk.sdu.wPage.Conjunction
import dk.sdu.wPage.Comparison
import dk.sdu.wPage.Parenthesis
import dk.sdu.wPage.Add
import dk.sdu.wPage.Sub
import dk.sdu.wPage.Mul
import dk.sdu.wPage.Div
import dk.sdu.wPage.Name
import dk.sdu.wPage.Whole
import dk.sdu.wPage.Decimal
import dk.sdu.wPage.LayoutContent
import dk.sdu.wPage.Index

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class WPageGenerator extends AbstractGenerator {

	//TODO fix terminals (nice, not necesary)
	//TODO line breaks (nice, not necesary)
	//TODO if can only use variables
	//TODO all types like textvalue - with numbers too (nice to have)
	//TODO advancetype variables need quotes (for now they are just removed)
	//TODO editview change variable - runtime if/else (not happening...?)
	//TODO parenthesis in if
	//TODO e.g. last-1  > current-5 gives nullpointer
	 
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		pageNames = resource.allContents.filter(Page).map[it.name].toList
		resource.allContents.filter(Page).forEach[generateHtmlPageFile(fsa)]
	}
	
	private var List<String> pageNames = new ArrayList;
	private val Map<String,Variable> mapOfVariables = new HashMap
	private var int currentIndex = 0;
	
	def generateHtmlPageFile(Page page, IFileSystemAccess2 fsa) {
		val pageName =page.name + ".html"
		fsa.generateFile(pageName, page.generateHTML)
		print(mapOfVariables)
	}
	
	def generateNavigationMethods(Page page){
		val size = pageNames.size 
		currentIndex = pageNames.indexOf(page.name)
		
		val previous = "function prev(){window.location.href = '" + pageNames.get((currentIndex-1).mod(size)) + ".html'} "
		val next = "function next(){window.location.href = '" + pageNames.get((currentIndex+1).mod(size)) + ".html'} "
		val goTo = "function goto(pageName){window.location.href =   pageName.concat('.html') }"
		val first = "function next(){window.location.href = '" + pageNames.get(0) + ".html'} "
		val last = "function next(){window.location.href = '" + pageNames.get(size-1) + ".html'} "
		
		
		previous + next + goTo
	}
	
	def generateVars(Page page){
		val vars = page.pagecontents.filter(Variable)
		vars.forEach[mapOfVariables.put(it.name,it)]
		val simple = vars.filter[!(it.value instanceof AdvancedType)]
		simple.join("")[ "var " + it.name + " = " +  /*"'" + it.getVariable + "'"*/ it.getVariable +";"] + " var _current = " + pageNames.indexOf(page.name) +";"
	}
	
	
	
	
	def double getVariableFromMap(Name name){
		val a = name.name.name
		val b = mapOfVariables.get(name.name)
		mapOfVariables.get(name.name.name).value.computeValue 
	} 
	
	
	def CharSequence getVariable(Variable variable) '''�if(variable.value instanceof AdvancedType) (variable.value as AdvancedType).generateAdvancedType else (variable.value as Type).simpleVar�'''
	
	def dispatch simpleVar(Text text) ''''�text.value.generateTextValue+"'"�'''
	def dispatch simpleVar(Boolean text) '''�text.value.toLowerCase�'''
	def dispatch simpleVar(Number text) '''�text.computeValue�'''
	
	def generateTextValue(TextValue textValue) '''�IF null !== textValue.string��textValue.string��ELSEIF null !== textValue.variable��(mapOfVariables.get(textValue.variable.name).value as Text).value.string��ENDIF�'''
	
	def int mod(int number, int modulo){
		(number % modulo + modulo) % modulo
	}
	
	def generateHTML(Page page) '''
	<html>
		<head>
			�IF page.pagecontents.exists[it instanceof Title]�
				<title>�page.pagecontents.filter(Title).get(0).value�</title>  ���Only one can exists
			�ENDIF�
			<script>
				�page.generateNavigationMethods�
				�page.generateVars�
			</script>
			�page.pagecontents.filter(Css).generateCssFiles�
		</head>
		<body>
		�FOR p : page.pagecontents.filter[it instanceof GroupedView|| it instanceof Include || it instanceof IfElse]�
			�p.generatePageBodyContent�
		�ENDFOR�
		</body>
	</html>	
	'''
	
	def generateCssFiles(Iterable<Css> css) '''
	�IF css.isEmpty� 
	�ELSE��css.join("\n")["<link rel= \"stylesheet\" href=\""+it.value] + "\">"��ENDIF�''' 
	
	
	//TODO dispatch
	def CharSequence generatePageBodyContent(LayoutContent groupedView) '''
		<div>
		�IF groupedView instanceof Include�
			�groupedView.include.getVariable�
		�ELSEIF groupedView instanceof IfElse� 
			�(groupedView as IfElse).handleConditionalLayout�
		�ELSEIF groupedView instanceof GroupedView�
			�FOR g: (groupedView as GroupedView).group�
				�IF (groupedView as GroupedView).group.size > 1�
				<div style="display:inline-block">
				�ENDIF�
					�g.generateAdvancedType�
				�IF (groupedView as GroupedView).group.size > 1�
				</div>
				�ENDIF�
			�ENDFOR�
		�ENDIF�
		</div>
	'''
	
	def dispatch generateAdvancedType(View view) '''
	<div �view.contents.filter(DisplayConfiguration).generateDisplayConfiguration�>
		�FOR i:view.contents�
		�i.generateViewContent�
		�ENDFOR�
	</div>
	'''
	
	def dispatch generateViewContent(Image image) '''�image.generateImage�'''
	def dispatch generateViewContent(Text text) '''�text.generateText�'''
	def dispatch generateViewContent(Editable edit) '''�edit.generateEditable�'''
	def dispatch generateViewContent(GroupedView group) '''�group.generatePageBodyContent�'''
	def dispatch generateViewContent(Include include) '''�include.generatePageBodyContent�'''
	def dispatch generateViewContent(Style style) ''''''  //TODO fix
	def dispatch generateViewContent(CssClass cssClass) ''''''
	
	def generateImage(Image image) '''<img src="�image.value�">'''
	
	def generateText(Text text) '''
	<p>�text.value.generateTextValue�</p>
	'''
	
	def generateEditable(Editable editable)'''
	<form>
		<input type="text" value="�editable.value�">
	</form>
	'''
	
	def dispatch CharSequence generateAdvancedType(Button button) '''
	<button type="button"�
	button.contents.filter(DisplayConfiguration).generateDisplayConfiguration�
	�IF button.contents.exists[it instanceof Click]��button.contents.filter(Click).join(" ")[it.buttonEvents] ��ENDIF�>
	�IF button.contents.exists[it instanceof Text]��button.contents.filter(Text).get(0).generateText��ENDIF�
	</button>
	'''
	
	def CharSequence getButtonEvents(Click click) { //Limited to alert and navigation, TODO dispatch
		if(click.click  instanceof Action ){
			(click.click as Action).buttonAction 
		} else if(click.click instanceof IfElse){
			(click.click as IfElse).handleIfElseAction
		}
	}
	
	def CharSequence handleIfElseAction(IfElse ifElse) {
		val ifside = ifElse.condition.computeBooleanExpression
		if(ifside) ifElse.ifAction.buttonAction
		else {
			if(ifElse.elseAction!==null) ifElse.elseAction.buttonAction
		}
	}
	
	def CharSequence handleConditionalLayout(IfElse ifElse){
		val ifside = ifElse.condition.computeBooleanExpression
		if(ifside) ifElse.ifAction.handleLayoutAction
		else {
			if(ifElse.elseAction!==null) ifElse.elseAction.handleLayoutAction
		}
	}
	
	def CharSequence handleLayoutAction(Action action){
		if(action.advancedType === null) return ""
		return action.advancedType.generateAdvancedType
	}
	
	def dispatch boolean computeBooleanExpression(Disjunction disjunction) {
		disjunction.left.computeBooleanExpression || disjunction.right.computeBooleanExpression
	}
	
	def dispatch boolean computeBooleanExpression(Conjunction conjunction) {
		conjunction.left.computeBooleanExpression && conjunction.right.computeBooleanExpression
	}
	
	def dispatch boolean computeBooleanExpression(Comparison booleanExp) {
		val left = booleanExp.left.computeExp
		val right = booleanExp.right?.computeExp
		switch (booleanExp.op) {
			case '==': left == right
			case '!=': left != right
			case '<': left < right
			case '>': left > right
			case '<=': left <= right
			case '>=': left >= right
			default: left>0
		}
	}
	
	def dispatch boolean computeBooleanExpression(Parenthesis booleanExp) {
		booleanExp.condition.computeBooleanExpression
	}
	
	def dispatch double computeExp(Index index) {
		switch(index.value){
			case 'current': currentIndex
			case 'last' : pageNames.size-1
			default: throw new Exception("You broke it")
		}  
	}
	
	
	def dispatch double computeExp(Add exp) {
		exp.left.computeExp + exp.right.computeExp
	}
	
	def dispatch double computeExp(Sub exp) {
		
		exp.left.computeExp - exp.right.computeExp
	}
	
	def dispatch double computeExp(Mul exp) {
		exp.left.computeExp * exp.right.computeExp
	}
	
	def dispatch double computeExp(Div exp) {
		exp.left.computeExp / exp.right.computeExp
	}
		
	def dispatch double computeExp(Number num) {
		num.value.computeExp
	}
	
	def dispatch double computeExp(Boolean num) {
		num.computeValue
	}
	
	def dispatch double computeExp(boolean num) {
		if(num) 1 else 0
	}
	
	def dispatch double computeExp(Whole whole) {
		whole.value
	}
	
	def dispatch double computeExp(Decimal decimal) {
		Double.parseDouble(decimal.value)
	}
	
	def dispatch double computeValue(Decimal decimal) {
		Double.parseDouble(decimal.value)
	}
	
	def dispatch double computeValue(Number number) {
		computeExp(number)
	}
	
	def dispatch double computeValue(Boolean bool) {
		if(bool.value.toLowerCase == "true") 1 else 0
	}
	
	def dispatch double computeExp(String variable) {
		switch(variable){
			case 'current': currentIndex
			case 'last' : pageNames.size-1
			default: throw new Exception("Will never happen")
		}
	}
	
	def dispatch double computeExp(Name variable) {
		variable.variableFromMap	
	}
	
	def buttonAction(Action action){
		val start = "onClick ='"
		val end = "'"
		start +	action.pageDirection.directionString+getScriptCall(action.script)+action.alert.getAlert	+end
	}
	
	def getAlert(Alert alert) {
		if(alert===null) ""
		else  "alert(\"" + alert.value.generateTextValue + "\")"
	}
	
	def getScriptCall(Script script ){
		if(script===null) return ""
		val methodStart = script.name +"("
		val methodEnd = ")"
		val middle = script.parameters.join(",")[it.generateTextValue]
		methodStart + middle + methodEnd
	}
	
	def directionString(String direction)'''�
		if(direction === null) return ""
		else
			switch (direction){
				case "next" : "next()"
				case "previous" : "prev()"
				case  direction.startsWith("goto") : "goto(\"" + direction.replace("goto ","").replace("\"","") + "\")"
				default: "next"
			}
	 �'''
	
	def generateDisplayConfiguration(Iterable<DisplayConfiguration> configurations) '''�configurations.filter(CssConfiguration).join(" ")[it.generateCssConfiguration]� style="�configurations.filter(ViewConfiguration).join(" ")[it.generateViewConfiguration]�"'''
	
	def dispatch generateViewConfiguration(Dimension dimension) '''
		�dimension.values.join(" ")[it.generateDimensionValue]�
	'''
	
	def dispatch generateDimensionValue(Height height) '''height:�height.value�;'''
	
	def dispatch generateDimensionValue(Width width) '''width:�width.value�;'''
	
	def dispatch generateViewConfiguration(Style style) '''
		�FOR s:style.styleDefinitions�
		���TODO: fix new lines
		�switch s {
			case "bold": "font-weight:bold;"
			case "italic": "font-style:italic;"
			case "underline": "text-decoration:underline;"
			case "float":"float:right;"
			default : ""
		}�
		�ENDFOR�
	'''
	
	def dispatch generateCssConfiguration(CssClass cssClass) '''class="�cssClass.value�"'''
	
	def dispatch generateCssConfiguration(CssId cssId) '''id="�cssId.value�"'''
	
	//TODO necesary if exists?
	def dispatch generateAdvancedType(Table table) '''
		<table �table.contents.filter(DisplayConfiguration).generateDisplayConfiguration�>
			�IF table.contents.exists[it instanceof Header]�
			�table.contents.filter(Header).get(0).generateTableHeader�
			�ENDIF�
			�IF table.contents.exists[it instanceof Row]�
			�table.contents.filter(Row).generateTableRows�
			�ENDIF�
		</table>
	'''
	
	def generateTableHeader(Header header) '''
	<tr>
		�FOR h: header.contents�
		<th>�h.generateTextValue�</th>
		�ENDFOR�
	</tr>
	'''
	
	def generateTableRows(Iterable<Row> rows) '''�rows.map[it.generateTableRow].join("")�'''
	
	def generateTableRow(Row row) '''
	<tr>
		�FOR c:row.contents�
		<td>�c.generateTextValue�</td>
		�ENDFOR�
	</tr>
	'''
}

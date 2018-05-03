/*
 * generated by Xtext 2.12.0
 */
package dk.sdu.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.wPage.Page
import dk.sdu.wPage.Title
import dk.sdu.wPage.GroupedView
import dk.sdu.wPage.View
import dk.sdu.wPage.Button
import dk.sdu.wPage.Dimension
import dk.sdu.wPage.Style
import dk.sdu.wPage.CssClass
import dk.sdu.wPage.CssId
import dk.sdu.wPage.ViewConfiguration
import dk.sdu.wPage.Height
import dk.sdu.wPage.Width
import dk.sdu.wPage.CssConfiguration
import dk.sdu.wPage.Text
import dk.sdu.wPage.Table
import dk.sdu.wPage.DisplayConfiguration
import dk.sdu.wPage.Header
import dk.sdu.wPage.Row
import dk.sdu.wPage.Image
import dk.sdu.wPage.Click
import java.util.List
import java.util.ArrayList
import dk.sdu.wPage.Variable
import dk.sdu.wPage.AdvancedType
import dk.sdu.wPage.Type

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class WPageGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		pageNames = resource.allContents.filter(Page).map[it.name].toList
		
		resource.allContents.filter(Page).forEach[generateHtmlPageFile(fsa)]
	}
	
	var List<String> pageNames = new ArrayList;
	
	
	
	def generateHtmlPageFile(Page page, IFileSystemAccess2 fsa) {
		val pageName =page.name + ".html"
		fsa.generateFile(pageName, page.generateHTML)
	}
	
	def generateNavigationMethods(Page page){
		val size = pageNames.size 
		val currentIndex = pageNames.indexOf(page.name)
		
		val previous = "prev(){window.location.href = '"+  pageNames.get((currentIndex-1).mod(size))     + ".html'} "
		val next = "next(){window.location.href = '"+  pageNames.get((currentIndex+1).mod(size))     + ".html'} "
		val goTo = "goto(pageName){window.location.href = 'pageName.concat('.html')'}"
		
		previous + next + goTo
	}
	
	def generateVars(Page page){
		val vars = page.pagecontents.filter(Variable)
		if(vars.isEmpty()) return ''''''
		
		vars.join("; ")["var " + it.name + " = " +  if(it.value instanceof AdvancedType) (it.value as AdvancedType).generateAdvancedType 
			else (it.value as Type).value
		]
	}
	
	
	
	def int mod(int number, int modulo){
		
		(number % modulo + modulo) % modulo
	} 
	
	def generateHTML(Page page) '''
	<html>
		<header>
			<script>
				�page.generateNavigationMethods�
				�page.generateVars�
			</script>
			�IF page.pagecontents.exists[it instanceof Title]�
				���TODO: alternative to find first
				<title>�page.pagecontents.filter(Title).findFirst[it instanceof Title].value�</title>
			�ENDIF�
		</header>
		<body>
			�FOR pagecontent:page.pagecontents.filter(GroupedView)�
			�pagecontent.generatePageBodyContent�
			�ENDFOR�
		</body>
	</html>	
	'''
	
	def generatePageBodyContent(GroupedView groupedView) '''
		�FOR g: groupedView.group�
		�g.generateAdvancedType�
		�ENDFOR�
	'''
	
	def dispatch generateAdvancedType(View view) '''
		<div �view.contents.filter(DisplayConfiguration).generateDisplayConfiguration�>
			�FOR i:view.contents.filter(Image)�
			�i.generateImage�
			�ENDFOR�
			�FOR t:view.contents.filter(Text)�
			�t.generateText�
			�ENDFOR�
		</div>
	'''
	
	def generateImage(Image image) '''<img src="�image.value�">'''
	
	def generateText(Text text) '''<p>�text.value�</p>'''
	
	def dispatch generateAdvancedType(Button button) '''
		<button type="button"�
		button.contents.filter(DisplayConfiguration).generateDisplayConfiguration�>
		�IF button.contents.exists[it instanceof Text]��button.contents.filter(Text).findFirst[it instanceof Text].value��ENDIF�
		�IF button.contents.exists[it instanceof Click]��button.contents.filter(Click).join(" ")[] ��ENDIF�
		</button>
	'''
	
	def getButtonEvents(Click click) {
		//val start = "onClick ='" + click. 
		
		
		
		
	}
	
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
			case "horizontal": ""
			case "vertical": ""
			default : ""
		}�
		�ENDFOR�
	'''
	
	def dispatch generateCssConfiguration(CssClass cssClass) '''class="�cssClass.value�"'''
	
	def dispatch generateCssConfiguration(CssId cssId) '''id="�cssId.value�"'''
	
	def dispatch generateAdvancedType(Table table) '''
		<table �table.contents.filter(DisplayConfiguration).generateDisplayConfiguration�>
			�IF table.contents.contains(Header)�
			�table.contents.filter(Header).findFirst[it instanceof Header].generateTableHeader�
			�ENDIF�
			�IF table.contents.contains(Row)�
			�table.contents.filter(Row).generateTableRows�
			�ENDIF�
		</table>
	'''
	
	def generateTableHeader(Header header) '''
	<tr>
		�FOR h: header.contents�
		<th>�h.value�</th>
		�ENDFOR�
	</tr>
	'''
	
	def generateTableRows(Iterable<Row> rows) '''�rows.map[it.generateTableRow]�'''
	
	def generateTableRow(Row row) '''
	<tr>
		�FOR c:row.contents�
		<td>�c.value�</td>
		�ENDFOR�
	</tr>
	'''
}

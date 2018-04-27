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

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class WPageGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		resource.allContents.filter(Page).forEach[generateHtmlPageFile(fsa)]
	}
	
	def generateHtmlPageFile(Page page, IFileSystemAccess2 fsa) {
		fsa.generateFile(page.name + ".html", page.generateHTML)
	}
	
	def CharSequence generateHTML(Page page) '''
	<html>
		<header>
			<script>
				
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
	
	def CharSequence generatePageBodyContent(GroupedView groupedView) '''
		�FOR g: groupedView.group�
		�g.generateAdvancedType�
		�ENDFOR�
	'''
	
	def dispatch CharSequence generateAdvancedType(View view) '''
		<div>
			
		</div>
	'''
	
	def dispatch CharSequence generateAdvancedType(Button button) '''
		<button type="button"�button.contents.filter(CssConfiguration).join(" ")[it.generateCssConfiguration]� style="�button.contents.filter(ViewConfiguration).join(" ")[it.generateViewConfiguration]�">�IF button.contents.exists[it instanceof Text]��button.contents.filter(Text).findFirst[it instanceof Text].value��ENDIF�</button>
	'''
	
	def dispatch CharSequence generateViewConfiguration(Dimension dimension) '''
		�dimension.values.map[it.generateDimensionValue].join(" ")�
	'''
	
	def dispatch CharSequence generateDimensionValue(Height height) '''height:�height.value�;'''
	
	def dispatch CharSequence generateDimensionValue(Width width) '''width:�width.value�;'''
	
	def dispatch CharSequence generateViewConfiguration(Style style) '''
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
	
	def dispatch CharSequence generateCssConfiguration(CssClass cssClass) '''class="�cssClass.value�"'''
	
	def dispatch CharSequence generateCssConfiguration(CssId cssId) '''id="�cssId.value�"'''
}

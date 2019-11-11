
)				fileGeneratedTable
LEFT OUTER JOIN	changelog cl
ON				fileGeneratedTable.change_number = cl.change_number
				and fileGeneratedTable.description = cl.description
				and fileGeneratedTable.is_setup = cl.is_setup
WHERE			cl.change_number is null
ORDER BY		fileGeneratedTable.change_number ASC

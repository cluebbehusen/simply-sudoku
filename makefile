SimplySudoku.pdx.zip: SimplySudoku.pdx
	zip -r SimplySudoku.pdx.zip SimplySudoku.pdx

SimplySudoku.pdx: source
	pdc -s source SimplySudoku.pdx

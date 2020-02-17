// Translate all EPS files to PDF (Linux only)
	if "$S_OS" == "Unix" {
		!find *.eps -exec epstopdf '{}' ';'
	}



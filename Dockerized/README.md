Remember to add this in your project's .clangd:

    Diagnostics:
      Suppress:
        - builtin_definition

...otherwise the addition of the GCC version of the system header files in the
compile_commands.json db (done via `post_process_compilation_database.py`) will
lead to *"re-definition of builtin"* errors that break the LSP from working.

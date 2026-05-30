package verilang.service

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import verilang.model.RunResult
import java.io.File
import java.util.concurrent.TimeUnit

class VeriLangService {

    private val json = Json { ignoreUnknownKeys = true; isLenient = true }

    private val projectRoot: File by lazy {
        val cwd = File(System.getProperty("user.dir"))
        if (cwd.name == "kotlin-app") cwd.resolve("..").canonicalFile else cwd.canonicalFile
    }

    private val rascalJar: File
        get() = listOf(
            projectRoot.resolve("rascal-shell-stable.jar"),
            projectRoot.parentFile?.resolve("rascal-shell-stable.jar")
        ).filterNotNull().firstOrNull { it.exists() } ?: projectRoot.resolve("rascal-shell-stable.jar")

    private val srcDir: File get() = projectRoot.resolve("src/main/rascal")

    suspend fun run(filePath: String): RunResult = withContext(Dispatchers.IO) {
        try {
            println("[VeriLangService] Ejecutando Rascal...")
            println("[VeriLangService] archivo : $filePath")
            println("[VeriLangService] jar     : ${rascalJar.absolutePath}")
            println("[VeriLangService] src     : ${srcDir.absolutePath}")

            val t0 = System.currentTimeMillis()
            val output = executeRascal(filePath)
            println("[VeriLangService] tiempo  : ${System.currentTimeMillis() - t0} ms")
            println("[VeriLangService] stdout  : ${output.length} chars")

            val jsonStr = extractJson(output)
            if (jsonStr == null) {
                println("[VeriLangService] ERROR: no se encontró JSON en la salida de Rascal")
                return@withContext RunResult(error = "Rascal no produjo JSON válido:\n$output")
            }

            json.decodeFromString<RunResult>(jsonStr)
        } catch (e: Exception) {
            println("[VeriLangService] excepción: ${e.message}")
            e.printStackTrace()
            RunResult(error = e.message ?: "Error desconocido")
        }
    }

    private fun executeRascal(filePath: String): String {
        if (!rascalJar.exists())
            throw RuntimeException("No se encontró rascal-shell-stable.jar en ${rascalJar.absolutePath}")
        if (!srcDir.exists())
            throw RuntimeException("No se encontró el directorio src/main/rascal en ${srcDir.absolutePath}")

        val jsonFile = File.createTempFile("verilang-", ".json").apply {
            deleteOnExit()
        }

        val cmd = listOf(
            "java",
            "-Dfile.encoding=UTF-8",
            "-Drascal.projectPath=${projectRoot.absolutePath}",
            "-jar", rascalJar.absolutePath,
            "RunnerJson",
            filePath,
            jsonFile.absolutePath
        )

        val process = ProcessBuilder(cmd)
            .directory(projectRoot)
            .redirectErrorStream(false)
            .start()
        process.outputStream.close()

        val stdoutFuture = java.util.concurrent.Executors.newSingleThreadExecutor()
            .submit<String> { process.inputStream.bufferedReader().readText() }
        val stderrFuture = java.util.concurrent.Executors.newSingleThreadExecutor()
            .submit<String> { process.errorStream.bufferedReader().readText() }

        val finished = process.waitFor(180, TimeUnit.SECONDS)
        if (!finished) {
            process.destroyForcibly()
            throw RuntimeException("Rascal tardó más de 180s y fue detenido")
        }

        val stdout = stdoutFuture.get()
        val stderr = stderrFuture.get()

        println("--- STDERR (${stderr.length} chars) ---")
        if (stderr.isNotBlank()) println(stderr)
        println("--- exit code: ${process.exitValue()} ---")

        if (process.exitValue() != 0 && stdout.isBlank())
            throw RuntimeException("Error de Rascal (exit ${process.exitValue()}):\n$stderr")

        val jsonFromFile = if (jsonFile.exists()) jsonFile.readText() else ""
        return if (jsonFromFile.isNotBlank()) jsonFromFile else stdout
    }

    private fun extractJson(output: String): String? {
        val clean = output
            .replace(Regex("\\x1b\\[[^a-zA-Z]*[a-zA-Z]"), "")
            .replace(Regex("\\x1b[^\\[\\x1b]"), "")

        var start = 0
        while (start < clean.length) {
            val brace = clean.indexOf('{', start)
            if (brace == -1) break
            var depth = 0; var inStr = false; var esc = false; var end = -1
            for (i in brace until clean.length) {
                val c = clean[i]
                if (esc)              { esc = false; continue }
                if (c == '\\' && inStr) { esc = true; continue }
                if (c == '"')         { inStr = !inStr; continue }
                if (!inStr) {
                    if (c == '{') depth++
                    else if (c == '}') { depth--; if (depth == 0) { end = i; break } }
                }
            }
            if (end != -1) {
                val candidate = clean.substring(brace, end + 1)
                try {
                    val parsed = Json.parseToJsonElement(candidate)
                    if (parsed is kotlinx.serialization.json.JsonObject && parsed.containsKey("success"))
                        return candidate
                } catch (_: Exception) {}
            }
            start = brace + 1
        }
        return null
    }
}

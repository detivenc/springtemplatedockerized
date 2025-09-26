package com.detivenc.github.kspringdocker

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class KspringdockerApplication

fun main(args: Array<String>) {
	runApplication<KspringdockerApplication>(*args)
}

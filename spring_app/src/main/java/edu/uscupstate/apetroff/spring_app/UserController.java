package edu.uscupstate.apetroff.spring_app;

import java.util.concurrent.atomic.AtomicLong;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {

    private final AtomicLong counter = new AtomicLong();

    @GetMapping("/hello")
    public Message hello(@RequestParam(value = "name", defaultValue = "World") String name) {
      return new Message(counter.incrementAndGet(), String.format("Hello %s!", name));
    }

}

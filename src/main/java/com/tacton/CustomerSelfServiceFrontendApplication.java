/*
 * The MIT License
 *
 * Copyright 2020 Tacton Systems AB
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package com.tacton;

import com.tacton.entities.Role;
import com.tacton.entities.User;
import com.tacton.entities.UserRole;
import com.tacton.services.RoleService;
import com.tacton.services.cpq.CartService;
import com.tacton.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.context.WebApplicationContext;

import java.util.HashSet;
import java.util.Set;

@SpringBootApplication
public class CustomerSelfServiceFrontendApplication extends SpringBootServletInitializer {


    @Autowired
    BCryptPasswordEncoder encoder;

    @Autowired
    UserService userService;

    @Autowired
    CartService cartService;

    @Autowired
    RoleService roleService;

    @Value("${admin_firstname}")
    private String adminFirstName;

    @Value("${admin_lastname}")
    private String adminLastName;

    @Value("${admin_username}")
    private String adminUsername;

    @Value("${admin_password}")
    private String adminPassword;

    @Value("${admin_email}")
    private String adminEmail;

    @Value("${css_default_account}")
    private String defaultAccount;

    @Value("${css_default_country}")
    private String defaultCountry;

    @Value("${css_default_currency}")
    private String defaultCurrency;



    public static void main(String[] args) {
        //SpringApplication.run(CustomerSelfServiceFrontendApplication.class, args);
        configureApplication(new SpringApplicationBuilder()).run(args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        SpringApplicationBuilder springApplicationBuilder = configureApplication(application);
        return springApplicationBuilder;
    }


    private static SpringApplicationBuilder configureApplication(SpringApplicationBuilder builder) {
        return builder.sources(CustomerSelfServiceFrontendApplication.class);
    }

    @Override
    protected WebApplicationContext run(SpringApplication application) {
        return super.run(application);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void createAdminUser() {

        Role roleUser = new Role();
        roleUser.setId(1);
        roleUser.setName("ROLE_USER");
        roleService.save(roleUser);

        Role roleAdmin = new Role();
        roleAdmin.setId(2);
        roleAdmin.setName("ROLE_ADMIN");
        roleService.save(roleAdmin);

        if(userService.findAll().size()==0) {
            User user1 = new User();
            user1.setName(adminFirstName);
            user1.setSurname(adminLastName);
            user1.setUsername(adminUsername);
            user1.setPassword(encoder.encode(adminPassword));
            user1.setEmail(adminEmail);
            user1.setAccount(defaultAccount);
            user1.setCountryOfInstallation(defaultCountry);
            user1.setCurrency(defaultCurrency);
            user1.setEnabled(true);


            Set<UserRole> userRoles = new HashSet<>();
            //userRoles.add(new UserRole(roleService.findByName("ROLE_USER"), user1));
            userRoles.add(new UserRole(roleService.findByName("ROLE_ADMIN"), user1));

            if (userService.findByUsername(user1.getUsername()) != null) {
                user1.setUserRoles(userService.findByUsername(user1.getUsername()).getUserRoles());
                userService.save(user1);
            } else {
                user1.setUserRoles(userRoles);
                userService.createUser(user1, userRoles);
            }
        }
        else{
            User admin = userService.findByUsername(adminUsername);
            if(admin!=null){
                admin.setPassword(encoder.encode(adminPassword));
                admin.setAccount(defaultAccount);
                admin.setCountryOfInstallation(defaultCountry);
                admin.setCurrency(defaultCurrency);
                userService.save(admin);
            }
        }

    }
}

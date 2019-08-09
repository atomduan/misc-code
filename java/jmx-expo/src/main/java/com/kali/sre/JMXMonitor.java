package com.kali.sre;

import com.sun.tools.attach.VirtualMachine;
import org.codehaus.jackson.JsonFactory;
import org.codehaus.jackson.JsonGenerator;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Array;
import java.net.MalformedURLException;
import java.rmi.UnmarshalException;
import java.util.HashMap;
import java.util.Set;
import javax.management.AttributeNotFoundException;
import javax.management.InstanceNotFoundException;
import javax.management.IntrospectionException;
import javax.management.MBeanAttributeInfo;
import javax.management.MBeanException;
import javax.management.MBeanInfo;
import javax.management.MBeanServerConnection;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;
import javax.management.ReflectionException;
import javax.management.openmbean.CompositeData;
import javax.management.openmbean.CompositeType;
import javax.management.openmbean.TabularData;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;

public class JMXMonitor {
    private final String url;
    private final String username;
    private final String password;

    private MBeanServerConnection mBeanServer = null;

    public JMXMonitor(String url, String username, String password) {
        this.url = url;
        this.username = username;
        this.password = password;
    }

    private void listBeans() throws IOException {
        try {
            // make credential
            String[] credential = {this.username, this.password};
            HashMap<String, Object> properties = new HashMap<>();
            properties.put("jmx.remote.credentials", credential);

            // connect to JVM
            JMXServiceURL serviceURL = new JMXServiceURL(url);
            JMXConnector connector = JMXConnectorFactory.connect(serviceURL, properties);
            this.mBeanServer = connector.getMBeanServerConnection();
            Set<ObjectName> names = this.mBeanServer.queryNames(new ObjectName("*:*"), null);

            // json writer to STDOUT
            PrintWriter writer = new PrintWriter(System.out, true);
            JsonFactory jsonFactory = new JsonFactory();
            JsonGenerator jg = jsonFactory.createJsonGenerator(writer);
            jg.disable(JsonGenerator.Feature.AUTO_CLOSE_TARGET);
            jg.useDefaultPrettyPrinter();
            jg.writeStartObject();

            jg.writeArrayFieldStart("beans");
            for (ObjectName oname : names) {
                MBeanInfo mbinfo;
                String code;
                //Object attributeinfo = null;
                try {
                    mbinfo = this.mBeanServer.getMBeanInfo(oname);
                    code = mbinfo.getClassName();
                } catch (InstanceNotFoundException | IntrospectionException | ReflectionException e) {
                    //Ignored for some reason the bean was not found so don't output it
                    // This is an internal error, something odd happened with reflection so
                    // log it and don't output the bean.
                    // This happens when the code inside the JMX bean threw an exception, so
                    // log it and don't output the bean.
                    continue;
                }

                jg.writeStartObject();
                jg.writeStringField("name", oname.toString());

                jg.writeStringField("modelerType", code);
                MBeanAttributeInfo[] attrs = mbinfo.getAttributes();
                for (MBeanAttributeInfo attr : attrs) {
                    writeAttribute(jg, oname, attr);
                }
                jg.writeEndObject();
            }
            jg.writeEndArray();
            jg.writeEndObject();
            jg.close();
        } catch (MalformedURLException | MalformedObjectNameException ignored) {
        }
    }

    private void writeAttribute(JsonGenerator jg, ObjectName oname, MBeanAttributeInfo attr) throws IOException {
        if (!attr.isReadable()) {
            return;
        }
        String attName = attr.getName();
        if ("modelerType".equals(attName)) {
            return;
        }
        if (attName.contains("=") || attName.contains(":")
                || attName.contains(" ")) {
            return;
        }
        Object value;
        try {
            value = this.mBeanServer.getAttribute(oname, attName);
        }
        catch (AttributeNotFoundException | MBeanException | RuntimeException | ReflectionException |
                InstanceNotFoundException | UnmarshalException e) {
            // UnsupportedOperationExceptions happen in the normal course of business,
            // RuntimeErrorException happens when an unexpected failure occurs in getAttribute
            // for example https://issues.apache.org/jira/browse/DAEMON-120
            //Ignored the attribute was not found, which should never happen because the bean
            //just told us that it has this attribute, but if this happens just don't output
            //the attribute.
            //The code inside the attribute getter threw an exception so log it, and
            // skip outputting the attribute
            // For some reason even with an MBeanException available to them Runtime exceptions
            //can still find their way through, so treat them the same as MBeanException
            //This happens when the code inside the JMX bean (setter?? from the java docs)
            //threw an exception, so log it and skip outputting the attribute
            //Ignored the mbean itself was not found, which should never happen because we
            //just accessed it (perhaps something unregistered in-between) but if this
            //happens just don't output the attribute.
            //Need security manager enabled
            return;
        }

        writeAttribute(jg, attName, value);
    }

    private void writeAttribute(JsonGenerator jg, String attName, Object value) throws IOException {
        jg.writeFieldName(attName);
        writeObject(jg, value);
    }

    private void writeObject(JsonGenerator jg, Object value) throws IOException {
        if (value == null) {
            jg.writeNull();
        } else {
            Class<?> c = value.getClass();
            if (c.isArray()) {
                jg.writeStartArray();
                int len = Array.getLength(value);
                for (int j = 0; j < len; j++) {
                    Object item = Array.get(value, j);
                    writeObject(jg, item);
                }
                jg.writeEndArray();
            } else if (value instanceof Number) {
                Number n = (Number) value;
                jg.writeNumber(n.toString());
            } else if (value instanceof Boolean) {
                Boolean b = (Boolean) value;
                jg.writeBoolean(b);
            } else if (value instanceof CompositeData) {
                CompositeData cds = (CompositeData) value;
                CompositeType comp = cds.getCompositeType();
                Set<String> keys = comp.keySet();
                jg.writeStartObject();
                for (String key : keys) {
                    writeAttribute(jg, key, cds.get(key));
                }
                jg.writeEndObject();
            } else if (value instanceof TabularData) {
                TabularData tds = (TabularData) value;
                jg.writeStartArray();
                for (Object entry : tds.values()) {
                    writeObject(jg, entry);
                }
                jg.writeEndArray();
            } else {
                jg.writeString(value.toString());
            }
        }
    }

    public static void main(String[] args) {
        try {
            if (args.length != 4 && args.length != 2) {
                return;
            }

            String username = "";
            String password = "";
            if (args.length == 4) {
                username = args[2];
                password = args[3];
            }

            String url;
            if ("by_pid".equals(args[0])) {
                url = getUrlByPid(args[1]);
            } else {
                String host = args[0];
                String port = args[1];
                url = "service:jmx:rmi:///jndi/rmi://" + host + ":" + port + "/jmxrmi";
            }

            JMXMonitor monitor = new JMXMonitor(url, username, password);
            monitor.listBeans();
        } catch (Exception ignored) {
        }
    }

    private static final String CONNECTOR_ADDRESS =
            "com.sun.management.jmxremote.localConnectorAddress";

    // ref: https://docs.oracle.com/javase/7/docs/technotes/guides/management/agent.html#gdhkz
    private static String getUrlByPid(String pid) throws Exception {

        // attach to the target application
        VirtualMachine vm = VirtualMachine.attach(pid);

        // get the connector address
        String connectorAddress = vm.getAgentProperties().getProperty(CONNECTOR_ADDRESS);

        if (connectorAddress != null) {
            return connectorAddress;
        }

        // no connector address, so we start the JMX agent
        String agent = vm.getSystemProperties().getProperty("java.home") +
                File.separator + "lib" + File.separator + "management-agent.jar";
        vm.loadAgent(agent);

        // agent is started, get the connector address
        connectorAddress = vm.getAgentProperties().getProperty(CONNECTOR_ADDRESS);
        return connectorAddress;
    }
}

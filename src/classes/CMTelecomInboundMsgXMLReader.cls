global class CMTelecomInboundMsgXMLReader {
	/**
	* @description Used to store data from XML Reader
	*/
    global class message {
        public String text {get; set;}
        public String reference {get; set;}
        public String sender {get; set;}
				public String receiver {get; set;}
				public String code {get; set;}
	}

    /**
	* @description Used to store data from GET and POST
	* @param XmlStreamReader which contains the XML that has to be read
	*/
    public static List<message> parseMessages(XmlStreamReader reader) {
        List<message> messages = new List<message>();
        message msg;

        while (reader.hasNext()) {
            // Is the next element an opening tag?
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                // Check if the first element is MSG
                if ('MSG' == reader.getLocalName()) {
                    // if opening tag of account is found initialize new message
                    msg = new message();
                }
                else if ('MESSAGE' == reader.getLocalName()) {
                    // If you find any other opening tag, extract the string value
                    msg.text = getValueFromTag(reader);
                }
                else if ('REFERENCE' == reader.getLocalName()) {
                    // If you find any other opening tag, extract the string value
                    msg.reference = getValueFromTag(reader);
                }
                else if ('RECEIVER' == reader.getLocalName()) {
                    // If you find any other opening tag, extract the string value
                    msg.receiver = getValueFromTag(reader);
                }
								else if ('SENDER' == reader.getLocalName()) {
                    // If you find any other opening tag, extract the string value
                    msg.sender = getValueFromTag(reader);
                }
								else if ('CODE' == reader.getLocalName()) {
                    // If you find any other opening tag, extract the string value
                    msg.code = getValueFromTag(reader);
                }
            }
            else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                // Is the next element an end tag? If yes is it an MSG or an Messages tag?
                if ('MSG' == reader.getLocalName()) {
                    // If you find end tag called message, push the message in list
                    messages.add(msg);
                }
                else if ('MESSAGES' == reader.getLocalName()) {
                    // We have reached end of file, just exit
                    break;
                }
            }
            reader.next();
    	}
        return messages;
    }
    /**
	* @description This is an extra function to read data between opening and closing tag. It will return the string of value from between tags.
	*/
    public static string getValueFromTag(XMLStreamReader reader) {
        String DataValue;

        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                DataValue = reader.getText();
            }
            reader.next();
        }

        return DataValue;
    }
}
# -------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for
# license information.
# --------------------------------------------------------------------------

import os
import asyncio
import uuid
from azure.iot.device.aio import IoTHubDeviceClient
from azure.iot.device import Message, X509

from dotenv import load_dotenv

load_dotenv()

messages_to_send = 10


async def main():
    ca_cert = os.getenv("IOTEDGE_ROOT_CA_CERT_PATH")
    hostname = os.getenv("IOTHUB_HOSTNAME")
    gatewayHostname = os.getenv("IOTEDGE_GATEWAY_HOSTNAME")
    device_id = os.getenv("X509_REGISTRATION_ID")

    certfile = open(ca_cert)
    root_ca_cert = certfile.read()

    x509 = X509(
        cert_file=os.getenv("X509_CERT_FILE"),
        key_file=os.getenv("X509_KEY_FILE"),
        pass_phrase=os.getenv("X509_PASS_PHRASE"),
    )

    device_client = IoTHubDeviceClient.create_from_x509_certificate(
        x509=x509,
        hostname=hostname,
        device_id=device_id,
        server_verification_cert=root_ca_cert,
        gateway_hostname=gatewayHostname
    )

    # Connect the client.
    await device_client.connect()

    async def send_test_message(i):
        print("sending message #" + str(i))
        msg = Message("test wind speed " + str(i))
        msg.message_id = uuid.uuid4()
        msg.correlation_id = "correlation-1234"
        msg.custom_properties["tornado-warning"] = "yes"
        await device_client.send_message(msg)
        print("done sending message #" + str(i))

    # send `messages_to_send` messages in parallel
    await asyncio.gather(*[send_test_message(i) for i in range(1, messages_to_send + 1)])

    # Finally, shut down the client
    await device_client.shutdown()


if __name__ == "__main__":
    asyncio.run(main())

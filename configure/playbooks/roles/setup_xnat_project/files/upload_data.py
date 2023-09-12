import csv
import pathlib
from typing_extensions import Annotated

import typer
import xnat

def _load_session_metadata(
    metadata_file: pathlib.Path,
) -> dict[str, str]:
    """Load info about a set of sessions

    Args:
        metadata_file (pathlib.Path): CSV file containing metadata about each session.
            Must contain at least the following columns
                - Project (the ID of the project)
                - Label (the label of the session)
                - Subject (the name of the subject, in the form SURNAME_FORENAME)
                - Scans (string containing a list of all the scans to be uploaded)

    Returns:
        dict[str, dict[str, str]]: dictionary in which the keys are the Session label and
            values are dictionaries containing the project ID, subject name, and the number
            of scans in the session.
    """

    sessions = {}
    with open(metadata_file, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            sessions[row['Label']] = {
                'project': row['Project'],
                'subject': row['Subject'],
                'n_scans': len(row['Scans'].split(',')),
            }

    return sessions


def _upload_data(
    connection: xnat.session.BaseXNATSession,
    sessions: dict[str, dict[str, str]],
    data_directory: pathlib.Path,
) -> None:
    """Upload session data to a project using XNATPy

    Args:
        connection (xnat.core.XNATSession): active connection to a server
        sessions (dict[str, dict[str, str]]): sessions to upload. The keys must be the session
            label, and the values must be dictionaries containing the project ID, subject name,
            and number of scans in each session.
        data_directory (pathlib.Path): path to the directory containing the data to upload. Each
            session must be archived into a file named 'subjectSurname_subjectForename_sessionLabel.zip',
            e.g. 'KENT_CLARK_0123456.zip' would contain the data for session '0123456' of subject
            'CLARK KENT'.
    """

    for session in sessions:

        project = sessions[session]['project']
        subject = sessions[session]['subject']
        n_scans = sessions[session]['n_scans']

        if session in connection.projects[project].experiments:
            print(f'session {session} of subject {subject} ({n_scans} scans) already exists, skipping')
            continue

        path = (data_directory / f"{subject}_{session}.zip").resolve()

        print(f'uploading session {session} of subject {subject} ({n_scans} scans) from file "{path}"...')
        connection.services.import_(
            path=path,
            project=project,
            subject=subject,
            experiment=session,
            overwrite="delete",
            content_type="application/zip",
            import_handler="SI",
        )


metadata_help = (
    "Path to a CSV file containing metadata about each session. Must be in the form "
    "that is produced by XNAT when downloading session metadata."
)
data_help = "Path to the directory containing the data to upload."

def upload_data(
    metadata_file: Annotated[str, typer.Option("--metadata", "-m", help=metadata_help)],
    data_directory: Annotated[str, typer.Option("--data", "-d", help=data_help)],
    user: Annotated[str, typer.Option("--user", "-u", help="XNAT username")],
    password: Annotated[str, typer.Option("--password", "-p", help="XNAT password")],
) -> None:
    """Upload a set of XNAT Sessions to a project

    Each session to upload must be archived into a file and stored in the 'data_directory'.

    Filenames must be of the form 'subjectSurname_subjectForename_sessionLabel.zip'.

    For example, 'KENT_CLARK_0123456.zip' would contain the data for session '0123456' of subject 'CLARK KENT'.

    """

    # Get full path to each file
    metadata_file = pathlib.Path(metadata_file).resolve()
    data_directory =pathlib.Path(data_directory).resolve()

    server = "localhost:8080"

    # Connect to the server
    connection = xnat.connect(
        server=f"http://{server}",
        user=user, password=password,
        verify=False,
    )

    # Get the Subject and number of scans for each Session
    sessions = _load_session_metadata(
        metadata_file=metadata_file,
    )

    # Now we can upload the data
    _upload_data(
        connection=connection,
        sessions=sessions,
        data_directory=data_directory,
    )

if __name__ == "__main__":
    typer.run(upload_data)

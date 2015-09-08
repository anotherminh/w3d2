DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255),
  lname VARCHAR(255)
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body TEXT,
  author_id INTEGER REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER REFERENCES questions(id),
  user_id INTEGER REFERENCES users(id)
);
DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER REFERENCES questions(id),
  parent_id INTEGER REFERENCES replies(id),
  user_id INTEGER REFERENCES users(id),
  body TEXT
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  question_id INTEGER REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Ned', 'Something'),
  ('Minh', 'Nguyen'),
  ('Sean', 'Walker');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('How do I SQL?', 'SQL is annoying and boring', 1),
  ('How many coins can you fit into the empire state building?', 'I dunno. Help.', 2),
  ('How do I get a job', 'I need money', 3),
  ('Can you speak Chinese?', 'I do', 1);

INSERT INTO
  question_follows(question_id, user_id)
VALUES
  (3, 1),
  (3, 2),
  (3, 3),
  (2, 2);

INSERT INTO
  replies(question_id, user_id, parent_id, body)
VALUES
  (3, 1, null, 'Go to App Academy'),
  (3, 2, 1, 'Go to Hack Reactor');

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (3, 1),
  (3, 2),
  (3, 3),
  (2, 2),
  (1, 1);
